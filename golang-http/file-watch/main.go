package main

import (
	"encoding/base64"
	"errors"
	"log"
	"os"
	"path/filepath"
	"text/template"

	"github.com/fsnotify/fsnotify"
	//"github.com/golang-jwt/jwt/v5"
)

var fileToWatch = "/var/run/secrets/kubernetes.io/serviceaccount/token"

//var fileToWatch = "/tmp/samplefile"

type Filters struct {
	Token string
}

func main() {
	lds_tpl_path := os.Getenv("ENVOY_LDS_TPL_PATH")
	lds_out_path := os.Getenv("ENVOY_LDS_OUT_PATH")
	lds_tpl_name := filepath.Base(lds_tpl_path)

	if _, err := os.Stat(lds_tpl_path); errors.Is(err, os.ErrNotExist) {
		log.Fatal(err)
	}

	tpl, _ := readFile(lds_tpl_path)
	log.Println("using template", tpl)
	//create on start up
	update(lds_tpl_path, lds_tpl_name, lds_out_path)
	// Create new watcher.
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		log.Fatal(err)
	}
	defer watcher.Close()

	// Start listening for events.
	go func() {
		for {
			select {
			case event, ok := <-watcher.Events:
				if !ok {
					return
				}
				log.Println("event:", event)
				replaced := event.Has(fsnotify.Write) || event.Has(fsnotify.Remove)
				if replaced {
					log.Println("modified file:", event.Name)
				}
				update(lds_tpl_path, lds_tpl_name, lds_out_path)
			case err, ok := <-watcher.Errors:
				if !ok {
					return
				}
				log.Println("error:", err)
			}
		}
	}()

	// Add a path.
	err = watcher.Add(fileToWatch)
	if err != nil {
		log.Fatal(err)
	}

	// Block main goroutine forever.
	<-make(chan struct{})
}

func update(tpl_path string, tpl_name string, out_path string) {

	token, err := readFile(fileToWatch)
	if err != nil {
		log.Fatal(err)
	}
	filter := Filters{
		Token: "Bearer " + base64.StdEncoding.EncodeToString(token),
	}

	log.Println("Updating ", out_path, "with ", tpl_path)
	tmpl, err := template.New(tpl_name).ParseFiles(tpl_path)
	if err != nil {
		log.Fatal(err)
	}

	file, err := os.Create(out_path)

	if err != nil {
		log.Fatal(err)
	}

	defer file.Close()

	err = tmpl.Execute(file, filter)
	if err != nil {
		log.Fatal(err)
	}

}

func readFile(filePath string) ([]byte, error) {
	log.Println("Reading ", filePath, "...")
	b, err := os.ReadFile(filePath)
	if err != nil {
		log.Fatal(err)
	}
	return b, err
}
