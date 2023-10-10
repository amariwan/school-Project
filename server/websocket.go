package main

import (
	"log"
	"net/http"

	"github.com/apsdehal/go-logger"
	"github.com/gorilla/websocket"
)

const (
	MAX_MSG_SIZE = 5000
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  2048,
	WriteBufferSize: 2048,
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

type WebSocket struct {
	Conn    *websocket.Conn
	Out     chan []byte
	In      chan []byte
	Events  map[string]EventHandler
	Islogin bool
}

func NewWebSocket(w http.ResponseWriter, r *http.Request, mylog *logger.Logger) (*WebSocket, error) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("[ERROR | SOCKET CONNECT] %v", err)
		return nil, err
	}
	// conn.SetWriteDeadline(time.Now().Add(MSG_TIMEOUT))
	ws := &WebSocket{
		Conn:    conn,
		Out:     make(chan []byte),
		In:      make(chan []byte),
		Events:  make(map[string]EventHandler),
		Islogin: false,
	}
	go ws.Reader(mylog)
	go ws.Writer(mylog)
	return ws, nil
}

func (ws *WebSocket) Reader(mylog *logger.Logger) {
	defer func() {
		ws.Conn.Close()
	}()
	ws.Conn.SetReadLimit(MAX_MSG_SIZE)
	for {
		_, message, err := ws.Conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("[ERROR] %v", err)
			}
			break
		}
		event, err := NewEventFromRaw(message)
		if err != nil {
			log.Printf("[ERROR | MSG] %v", err)
		} else {
			mylog.DebugF("[MSG] %v", event)
		}
		if action, ok := ws.Events[event.Name]; ok {
			action(event)
		}
	}
}

func (ws *WebSocket) Writer(mylog *logger.Logger) {
	for {
		select {
		case message, ok := <-ws.Out:
			if !ok {
				//log.Printf("hier ist nessage %v", ok)
				ws.Conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}
			writer, err := ws.Conn.NextWriter(websocket.TextMessage)
			if err != nil {
				//log.Printf("hier ist nessage in err %v", err)
				return
			}
			//log.Printf("hier ist nessage %v", message)
			writer.Write(message)
			writer.Close()
		}
	}
}

func (ws *WebSocket) On(event string, action EventHandler) *WebSocket {
	ws.Events[event] = action
	return ws
}
