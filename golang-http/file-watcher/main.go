package main

import (
	"fmt"
	"log"
	"os"
	"text/template"

	"github.com/fsnotify/fsnotify"
)

// var fileToWatch = "/var/run/secrets/kubernetes.io/serviceaccount/token"
var fileToWatch = "/tmp/samplefile"

type Filters struct {
	Token string
}

func main() {
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
				if event.Has(fsnotify.Write) {
					log.Println("modified file:", event.Name)
				}
				update()
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

func update() {
	var tmplFile = "fc.tmpl"
	tmpl, err := template.New(tmplFile).ParseFiles(tmplFile)
	if err != nil {
		panic(err)
	}
	filter := Filters{
		Token: readToken(fileToWatch),
	}

	err = tmpl.Execute(os.Stdout, filter)
	if err != nil {
		panic(err)
	}

}

func readToken(filePath string) string {
	b, err := os.ReadFile(filePath)

	if err != nil {
		fmt.Print(err)
	} else {
		fmt.Print(b)
	}
	return string(b)
}
