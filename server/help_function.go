package main

import (
	"bufio"
	"flag"
	"os"
	"runtime"
	"strconv"
	"strings"
	"time"

	"github.com/apsdehal/go-logger"
	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/mysql"
)

var dateOfToScanFile time.Time

type Abteilung struct {
	gorm.Model
	Abteilungsnummer  int `gorm:"primarykey;auto_increment;not_null"`
	Abteilungszeichen string
}

type Mitarbeiter struct {
	gorm.Model
	Mitarbeitersnummer string `gorm:"primarykey;auto_increment;not_null"`
	Mitarbeitername    string
	Abteilungsnummer   int
	Abteilung          Abteilung  `gorm:"polymorphic:owner"`
	Maschine           []Maschine `gorm:"many2many:mitarbeiter-maschine"`
}

type Maschine struct {
	gorm.Model
	Maschinennummer         int `gorm:"primarykey;auto_increment;not_null"`
	Betriebsdauermaschinest int
	Mitarbeiter             []Mitarbeiter `gorm:"many2many:mitarbeiter-maschine"`
}

type Werkstuck struct {
	gorm.Model
	Werkstucknummer    int `gorm:"primarykey;auto_increment;not_null"`
	Werkstuckzeichnung string
	Otg                float64
	Utg                float64
	Normwert           float64
	Werkstuckeinheit   string
	Maschinennummer    int
	Maschine           Maschine `gorm:"polymorphic:owner"`
}

type Messung struct {
	gorm.Model
	Protokolnummer  int `gorm:"primarykey;auto_increment;not_null"`
	Werkstucknummer int
	werkstuck       Werkstuck `gorm:"polymorphic:owner"`
}

type Stichprobe struct {
	gorm.Model
	Stichprobeid     string `gorm:"primarykey;auto_increment;not_null"`
	Stichprobenummer int
	Datumuhrzeit     time.Time
	Protokolnummer   int
	Messung          Messung `gorm:"polymorphic:owner"`
}

type Messwerte struct {
	gorm.Model
	Messwertnummer   int `gorm:"primarykey;auto_increment;not_null"`
	Messwert         float64
	Stichprobenummer int
	Stichprobe       Stichprobe `gorm:"polymorphic:owner"`
}

func parseCommandLineArguments(mylog *logger.Logger) (int, bool, bool) {
	var level int
	var isToBeRestored bool
	var isLinux bool
	if runtime.GOOS == "Linux" {
		isLinux = true
	} else {
		isLinux = false
	}

	flag.IntVar(&level, "l", 2, "LogLevel")
	flag.BoolVar(&isToBeRestored, "r", false, "if the database should be restored (default false)")
	flag.Parse()

	mylog.DebugF("level is---- %v\n", level)

	return level, isToBeRestored, isLinux
}

func int2LogLevel(level int) logger.LogLevel {
	switch level {
	case 1:
		return logger.CriticalLevel
	case 2:
		return logger.ErrorLevel
	case 3:
		return logger.WarningLevel
	case 4:
		return logger.NoticeLevel
	case 5:
		return logger.InfoLevel
	case 6:
		return logger.DebugLevel
	default:
		return logger.ErrorLevel
	}
}

func databaseInitialization(db *gorm.DB, isToBeRestored bool, isLinux bool, logLevel *logger.Logger) error {
	CreateTables(db, isToBeRestored, isLinux, logLevel)
	//  get a few jokes in joke table
	return readFromFileAndInsertInDataBase(logLevel, db)
}

func readFromFileAndInsertInDataBase(mylog *logger.Logger, db *gorm.DB) error {
	path := "Testdata.csv"
	toScanFile, err1 := os.Open(path)
	if err1 != nil {
		mylog.DebugF("err is---- %v\n", err1)
	}
	MyFile, err := os.Stat(path)
	if err != nil {
		mylog.DebugF("err is---- %v\n", err)
	}
	dateOfToScanFile = MyFile.ModTime()
	mylog.DebugF("level is---- %v\n", dateOfToScanFile)
	defer toScanFile.Close()

	scanner := bufio.NewScanner(toScanFile)
	var configData []string
	for scanner.Scan() {
		configData = append(configData, scanner.Text())
	}

	insertIn2DatabaseTable(db, mylog, configData)
	return nil
}

func CreateTables(db *gorm.DB, isToBeRestored bool, isLinux bool, mylog *logger.Logger) error {
	var err error
	err = createTableAbteilung(db, isToBeRestored, mylog) // Create Database Tables
	if err != nil {
		//return err
	}
	err = createTableMitarbeiter(db, isToBeRestored, mylog) // Create Database Tables
	if err != nil {
		//return err
	}
	db.Model(&Mitarbeiter{}).
		AddForeignKey("Abteilungsnummer", "abteilungs(Abteilungsnummer)", "CASCADE", "CASCADE")
	err = createTableMaschine(db, isToBeRestored, mylog) // Create Database Tables
	if err != nil {
		//return err
	}
	err = createTableWerkstuck(db, isToBeRestored, mylog) // Create Database Tables
	db.Model(&Werkstuck{}).
		AddForeignKey("Maschinennummer", "maschines(Maschinennummer)", "CASCADE", "CASCADE")
	if err != nil {
		//return err
	}
	err = createTableMessung(db, isToBeRestored, mylog) // Create Database Tables
	db.Model(&Messung{}).
		AddForeignKey("Werkstucknummer", "werkstucks(Werkstucknummer)", "CASCADE", "CASCADE")
	if err != nil {
		//return err
	}
	err = createTableStichprobe(db, isToBeRestored, mylog) // Create Database Tables
	db.Model(&Stichprobe{}).
		AddForeignKey("Protokolnummer", "messungs(Protokolnummer)", "CASCADE", "CASCADE")
	if err != nil {
		//return err
	}
	err = createTableMesswerte(db, isToBeRestored, mylog) // Create Database Tables
	db.Model(&Messwerte{}).
		AddForeignKey("Stichprobenummer", "stichprobes(Stichprobenummer)", "CASCADE", "CASCADE")
	if err != nil {
		//return err
	}
	return nil
}

func insertIn2DatabaseTable(db *gorm.DB, mylog *logger.Logger, configData []string) {
	mylog.DebugF("Inserting in the dataBase ...")
	stichProbeNumber := 0
	db.Model(&Stichprobe{}).Count(&stichProbeNumber)
	for i := 0; i < len(configData); i++ {
		if i > 0 {
			var stichProbe = strings.Split(configData[i], ",")

			for j := 0; j < len(stichProbe); j++ {
				if j == 0 {
					result := db.Create(&Stichprobe{Stichprobenummer: stichProbeNumber, Datumuhrzeit: time.Now()})
					if result.Error != nil {
						mylog.CriticalF("in InsertJoke %q\n", result.Error)
					}

				} else {
					messwer, _ := strconv.ParseFloat(stichProbe[j], 64)
					result := db.Create(&Messwerte{Messwert: messwer, Stichprobenummer: stichProbeNumber})
					if result.Error != nil {
						mylog.CriticalF("in InsertJoke %q\n", result.Error)
					}
				}

			}
			stichProbeNumber++
		}

	}
}

func createTableAbteilung(db *gorm.DB, isToBeRestored bool, mylog *logger.Logger) error {

	if isToBeRestored {
		if db.HasTable(&Abteilung{}) {
			//fmt.Println("in if .............")
			db.DropTable(&Abteilung{})
		}
	}

	mylog.DebugF("Abteilung table created")
	db.AutoMigrate(&Abteilung{})
	return nil
}

func createTableMitarbeiter(db *gorm.DB, isToBeRestored bool, mylog *logger.Logger) error {

	if isToBeRestored {
		if db.HasTable(&Mitarbeiter{}) {
			//fmt.Println("in if .............")
			db.DropTable(&Mitarbeiter{})
		}
	}

	mylog.DebugF("Mitarbeiter table created")
	db.AutoMigrate(&Mitarbeiter{})
	return nil
}
func createTableMaschine(db *gorm.DB, isToBeRestored bool, mylog *logger.Logger) error {

	if isToBeRestored {
		if db.HasTable(&Maschine{}) {
			//fmt.Println("in if .............")
			db.DropTable(&Maschine{})
		}
	}

	mylog.DebugF("Maschine table created")
	db.AutoMigrate(&Maschine{})
	return nil
}

func createTableWerkstuck(db *gorm.DB, isToBeRestored bool, mylog *logger.Logger) error {

	if isToBeRestored {
		if db.HasTable(&Werkstuck{}) {
			//fmt.Println("in if .............")
			db.DropTable(&Werkstuck{})
		}
	}

	mylog.DebugF("Werkstuck table created")
	db.AutoMigrate(&Werkstuck{})
	return nil
}
func createTableMessung(db *gorm.DB, isToBeRestored bool, mylog *logger.Logger) error {

	if isToBeRestored {
		if db.HasTable(&Messung{}) {
			//fmt.Println("in if .............")
			db.DropTable(&Messung{})
		}
	}

	mylog.DebugF("Messung table created")
	db.AutoMigrate(&Messung{})
	return nil
}
func createTableStichprobe(db *gorm.DB, isToBeRestored bool, mylog *logger.Logger) error {

	if isToBeRestored {
		if db.HasTable(&Stichprobe{}) {
			//fmt.Println("in if .............")
			db.DropTable(&Stichprobe{})
		}
	}

	mylog.DebugF("Stichprobe table created")
	db.AutoMigrate(&Stichprobe{})
	return nil
}
func createTableMesswerte(db *gorm.DB, isToBeRestored bool, mylog *logger.Logger) error {

	if isToBeRestored {
		if db.HasTable(&Messwerte{}) {
			//fmt.Println("in if .............")
			db.DropTable(&Messwerte{})
		}
	}

	mylog.DebugF("Messwerte table created")
	db.AutoMigrate(&Messwerte{})
	return nil
}
