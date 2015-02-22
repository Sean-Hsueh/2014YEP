package main

import (
  "encoding/json"
  "fmt"
  "net/http"
  "io/ioutil"
  "log"
  "sync"
)

var checkin_dict map[string]map[string]string
var mutex = &sync.Mutex{}

func clear_data(res http.ResponseWriter, req *http.Request){

    checkin_dict = make(map[string]map[string]string)
    fmt.Fprintln(res, "All data had been cleared!")
}

func get_results(res http.ResponseWriter, req *http.Request){

    _, err := ioutil.ReadAll(req.Body)
    if err != nil {
    }

    jsonString, _ := json.MarshalIndent(checkin_dict, "", "    ")
    fmt.Fprintln(res, string(jsonString))
}

func check_in(res http.ResponseWriter, req *http.Request){

    //fmt.Fprintln(res, "Hi, req = %s\n", req)
    body, err := ioutil.ReadAll(req.Body)
    if err != nil {
    }
    log.Println("body", string(body))

    var user_detail map[string]string
    json.Unmarshal(body, &user_detail)

    log.Println("user_detail = ", user_detail)

    if _, ok := checkin_dict[user_detail["ID"]]; ok {
        log.Println(checkin_dict)
        fmt.Fprint(res, "EXISTED")
    } else {
        mutex.Lock()
        checkin_dict[user_detail["ID"]] = user_detail
        mutex.Unlock()
        log.Println(checkin_dict)

        fmt.Fprint(res, "OK")
    }
}

func check(e error) {
    if e != nil {
        panic(e)
    }
}

func web_page(res http.ResponseWriter, req *http.Request){
    //dat, err := ioutil.ReadFile("/tmp/sample.html")
    dat, err := ioutil.ReadFile("/home/sean/sample.html")
    check(err)
    //fmt.Print(string(dat))
    fmt.Fprintln(res, string(dat))
}

func results_kevin(res http.ResponseWriter, req *http.Request){
    //dat, err := ioutil.ReadFile("/tmp/sample.html")
    dat, err := ioutil.ReadFile("/home/sean/result_kevin.hml")
    check(err)
    //fmt.Print(string(dat))
    fmt.Fprintln(res, string(dat))
}

func main(){

  checkin_dict = make(map[string]map[string]string)

  fs := http.FileServer(http.Dir("/home/sean/YEP_wireframw"))
  http.Handle("/", fs)

  http.HandleFunc("/check_in", check_in)
  http.HandleFunc("/results", get_results)
  http.HandleFunc("/cleardata", clear_data)
  http.HandleFunc("/sample", web_page)
  http.HandleFunc("/results_kevin", results_kevin)
  fmt.Println("listening...")
  err:= http.ListenAndServe(":8083", nil)
  if err!= nil{
    panic(err)
  }
}
