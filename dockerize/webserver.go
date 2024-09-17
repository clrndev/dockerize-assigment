package main

import (
	"bufio"
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/cleitonnovotni/take-home-assignment-main/webserver/articlehandler"
	"github.com/go-playground/validator"

	_ "github.com/go-sql-driver/mysql"
)

type DatabaseConfiguration struct {
	User     string `validate:"required"`
	Password string `validate:"required"`
	Protocol string `validate:"required" default:"tcp"`
	Host     string `validate:"required"`
	Port     string `validate:"required" default:"3306"`
	Dbname   string `validate:"required"`
}

func generateDsn(config DatabaseConfiguration) error {
	validator := validator.New()
	err := validator.Struct(config)
	if err != nil {
		return err
	}

	dsn := fmt.Sprintf("%s:%s@%s(%s:%s)/%s", config.User, config.Password, config.Protocol, config.Host, config.Port, config.Dbname)

	return os.WriteFile("server.confi", []byte(dsn), 0600)
}

func init() {
	if _, noLog := os.Stat("/log.txt"); os.IsNotExist(noLog) {
		newLog, err := os.Create("/log.txt")
		if err != nil {
			log.Fatal(err)
		}
		newLog.Close()
	}

	if _, config := os.Stat("server.confi"); os.IsNotExist(config) {
		config := DatabaseConfiguration{
			User:     os.Getenv("MYSQL_USER"),
			Password: os.Getenv("MYSQL_PASSWORD"),
			Protocol: "tcp",
			Host:     os.Getenv("MYSQL_HOST"),
			Port:     os.Getenv("MYSQL_PORT"),
			Dbname:   os.Getenv("MYSQL_DB"),
		}
		err := generateDsn(config)
		check(err)
	}

	dbString := readConfig("server.confi")
	var err error
	db, err := sql.Open("mysql", dbString)
	check(err)
	err = db.Ping()
	check(err)
	dbChecker := time.NewTicker(time.Minute)
	articlehandler.PassDataBase(db)
	go checkDB(dbChecker, db)
}

func main() {
	http.Handle("/", http.FileServer(http.Dir("./src")))
	http.HandleFunc("/articles/", articlehandler.ReturnArticle)
	http.HandleFunc("/index.html", articlehandler.ReturnHomePage)
	http.HandleFunc("/api/articles", articlehandler.ReturnArticlesForHomePage)
	http.HandleFunc("/preStopHook", func(w http.ResponseWriter, r *http.Request) {
		for i := 0; i < 10; i++ {
			time.Sleep(1 * time.Second)
			log.Println(fmt.Sprintf("Server is shutting down in %d seconds", 10-i))
		}
		w.Write([]byte("Server is shutting down"))
	})
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func readConfig(s string) string {
	config, err := os.Open(s)
	check(err)
	defer config.Close()

	scanner := bufio.NewScanner(config)
	scanner.Scan()
	return scanner.Text()

}

func check(err error) {
	if err != nil {
		errorLog, osError := os.OpenFile("/log.txt", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
		if osError != nil {
			log.Fatal(err)
		}
		defer errorLog.Close()
		textLogger := log.New(errorLog, "go-webserver", log.LstdFlags)
		switch err {
		case http.ErrMissingFile:
			log.Print(err)
			textLogger.Fatalln("File missing/cannot be accessed : ", err)
		case sql.ErrTxDone:
			log.Print(err)
			textLogger.Fatalln("SQL connection failure : ", err)
		}
		log.Println("An error has occured : ", err)
	}
}

func checkDB(t *time.Ticker, db *sql.DB) {
	for i := range t.C {
		err := db.Ping()
		if err != nil {
			fmt.Println("Db connection failed at : ", i)
			check(err)
		} else {
			fmt.Println("Db connection successful : ", i)
		}
	}
}
