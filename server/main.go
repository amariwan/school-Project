package main

import (
	//"bufio"
	"net/http"
	"strconv"

	//"net/http"
	"os"

	"github.com/apsdehal/go-logger"
	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/mysql"
)

func main() {
	var errorWithLogin error
	setLogLevel, errorWithLogin := logger.New("test", 1, os.Stdout)
	if errorWithLogin != nil {
		panic(errorWithLogin) // Check for error
	}
	setLogLevel.SetLogLevel(logger.ErrorLevel)
	level, isToBeRestored, isLinux := parseCommandLineArguments(setLogLevel)
	debugLevel := int2LogLevel(level)
	setLogLevel.SetLogLevel(debugLevel)
	//var st string
	//counter := 1
	// if isToBeRestored {
	// 	os.Remove("sqlite-database.db") // I delete the file to avoid duplicated records. SQLite is a file based database.
	// }
	setLogLevel.DebugF("Creating sqlite3gorm.db...")
	database := Connect()
	//sqliteDatabase.Exec("DROP TABLE IF EXISTS rs;")
	defer database.Close()
	//ToDo isToBeRestored use
	purgeDB(database)
	databaseInitialization(database, isToBeRestored, isLinux, setLogLevel)

	http.Handle("/", http.FileServer(http.Dir("./assets")))
	http.HandleFunc("/ws", func(w http.ResponseWriter, r *http.Request) {

		ws, err := NewWebSocket(w, r, setLogLevel)
		if err != nil {
			panic(err)
		}
		ws.On("scan", func(e *Event) {

			path := "Testdata.csv"
			MyFile, err := os.Stat(path)
			if err != nil {
				setLogLevel.DebugF("level is---- %v\n", level)
			}
			newDateOfToScanFile := MyFile.ModTime()
			if dateOfToScanFile.Before(newDateOfToScanFile) {
				if e.IsDataBaseToBeRestored {
					purgeDB(database)
					databaseInitialization(database, isToBeRestored, isLinux, setLogLevel)
				} else {
					readFromFileAndInsertInDataBase(setLogLevel, database)
				}

			}
			createResponse(database, e)
			ws.Out <- (e).Raw()
		})
		ws.On("getValues", func(e *Event) {
			createResponse(database, e)
			ws.Out <- (e).Raw()
		})
		ws.On("message", func(e *Event) {
			ws.Out <- (e).Raw()
		})

		ws.On("/", func(e *Event) {
			var messWerte []float32
			rows, _ := database.Model(&Messwerte{}).Select("messwert").Where("stichprobenummer = ? ", "0").Rows()
			defer rows.Close()
			for rows.Next() {
				var messWert float32
				rows.Scan(&messWert)
				messWerte = append(messWerte, messWert)
			}
			e.Name = "scan"
			e.Data = append(e.Data, messWerte)
			ws.Out <- (e).Raw()
		})

	})
	http.ListenAndServe(":8082", nil)
}

func createResponse(database *gorm.DB, e *Event) {
	count := 0
	database.Model(&Stichprobe{}).Count(&count)
	for i := 0; i < count; i++ {
		var messWerte []float32
		rows, _ := database.Model(&Messwerte{}).Select("messwert").Where("stichprobenummer = ? ", strconv.Itoa(i)).Rows()
		defer rows.Close()
		for rows.Next() {
			var messWert float32
			rows.Scan(&messWert)
			messWerte = append(messWerte, messWert)
		}
		if i == 0 && len(e.Data) > 0 {
			e.Name = "getValues"
			e.Data[0] = messWerte

		} else {
			e.Name = "getValues"
			e.Data = append(e.Data, messWerte)
		}
	}
}

func join2Array(array1 []int, array2 []int) []int {
	for i := 0; i < len(array1); i++ {
		array2 = append(array2, array1[i])
	}
	return array2
}

func purgeDB(db *gorm.DB) {
	if db.HasTable(&Maschine{}) {
		db.DropTable(&Maschine{})
	}
	if db.HasTable(&Werkstuck{}) {
		db.DropTable(&Werkstuck{})
	}
	if db.HasTable(&Messung{}) {
		db.DropTable(&Messung{})
	}
	if db.HasTable(&Stichprobe{}) {
		db.DropTable(&Stichprobe{})
	}
	if db.HasTable(&Messwerte{}) {
		db.DropTable(&Messwerte{})
	}
}
