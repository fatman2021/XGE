' include XGE header file
#LibPath "..\..\..\library"
#Include "..\..\..\include\xge.bi"



' Init xywh Game Engine
xge.Init(800, 600, XGE_INIT_WINDOW Or XGE_INIT_ALPHA, XGE_INIT_ALL, "XGE - draw shape")

' draw point
xge.shape.Pixel(30, 20, &HFFFF0000)
xge.shape.Pixel(31, 20, &HFF00FF00)
xge.shape.Pixel(30, 21, &HFFFFFFFF)
xge.shape.Pixel(31, 21, &HFF0000FF)

' draw line
xge.shape.Lines(30, 30, 100, 30, &HFFFF0000)
xge.shape.LinesEx(30, 40, 100, 40, &HFF0000FF, &B00001111000011110000111100001111)
xge.shape.LinesEx(30, 50, 100, 50, &HFF00FF00, &B10101010101010101010101010101010)

' draw rect
xge.shape.Rect(30, 50,100, 100, &HFF0000FF)
xge.shape.RectEx(40, 60,90, 90, &HFF00FF00, &B01010101010101010101010101010101)
xge.shape.RectFull(50, 70,80, 80, &HFFFF0000)

' draw circ
xge.shape.Circ(200, 100, 80, &HFFFF0000)
xge.shape.CircEx(200, 100, 80, &HFF00FFFF, 0.8)
xge.shape.CircFull(200, 100, 60, &HFF00FF00)
xge.shape.CircFullEx(200, 100, 60, &HFF0000FF, 0.6)
xge.shape.CircArc(400, 100, 80, &HFFFF8080, 90, 180, 0.7)

' wait 5s
Sleep 5000

' release menory by XGE
xge.Unit()
