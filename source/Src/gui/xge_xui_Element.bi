


Extern XGE_EXTERNCLASS



Namespace xui
	
	
	
	' 构造函数 [元素基类]
	Constructor Element() XGE_EXPORT_OBJ
		Image = New xge.Surface()
		Childs.Parent = @This
		ClassID = XUI_CLASS_ELEMENT
	End Constructor
	Constructor Element(iLayoutRuler As Integer = XUI_LAYOUT_RULER_PIXEL, x As Integer = 0, y As Integer = 0, w As Integer = 80, h As Integer = 24, iLayoutMode As Integer = XUI_LAYOUT_COORD, sIdentifier As ZString Ptr = NULL) XGE_EXPORT_OBJ
		Image = New xge.Surface()
		Childs.Parent = @This
		ClassID = XUI_CLASS_ELEMENT
		Layout.Ruler = iLayoutRuler
		Layout.w = w
		Layout.h = h
		If iLayoutRuler = XUI_LAYOUT_RULER_PIXEL Then
			Layout.Rect.x = x
			Layout.Rect.y = y
			Layout.Rect.w = w
			Layout.Rect.h = h
		EndIf
		LayoutMode = iLayoutMode
		If sIdentifier Then
			strncpy(@Identifier, sIdentifier, 31)
			Identifier[31] = 0
		EndIf
	End Constructor
	
	' 析构函数
	Destructor Element() XGE_EXPORT_OBJ
		If Image Then
			Delete Image
		EndIf
	End Destructor
	
	' 应用布局
	Sub Element.LayoutApply() XGE_EXPORT_OBJ
		If LayoutMode = XUI_LAYOUT_COORD Then
			' 坐标布局只计算元素的场景位置
			Dim c As Integer = Childs.StructCount
			For i As Integer = 1 To c
				Dim ele As xui.Element Ptr
				ele = *Cast(xui.Element Ptr Ptr, Childs.GetPtrStruct(i))
				ele->Layout.ScreenCoord.x = ele->Layout.Rect.x + Layout.ScreenCoord.x
				ele->Layout.ScreenCoord.y = ele->Layout.Rect.y + Layout.ScreenCoord.y
				' 让子元素也应用布局
				ele->LayoutApply()
			Next
		Else
			Dim c As Integer = Childs.StructCount
			' 第一个循环，检查父对象是否正确 [将父对象不是自己的子对象删掉，避免出现布局干扰的情况]
			For i As Integer = c To 1 Step -1
				Dim ele As xui.Element Ptr
				ele = *Cast(xui.Element Ptr Ptr, Childs.GetPtrStruct(i))
				If ele->Parent <> @This Then
					Childs.DeleteStruct(i)
				EndIf
			Next
			' 第二个循环，计算剩余空间和比例尺总和
			Dim cw As Integer = 0
			Dim ch As Integer = 0
			Dim ar As Integer = 0	' 比例尺度
			Dim rs As Integer = 0	' 剩余空间
			c = Childs.StructCount
			For i As Integer = 1 To c
				Dim ele As xui.Element Ptr
				ele = *Cast(xui.Element Ptr Ptr, Childs.GetPtrStruct(i))
				If ele->Visible Then
					Select Case ele->Layout.Ruler
						Case XUI_LAYOUT_RULER_PIXEL
							' 宽高用像素表示
							cw += ele->Layout.RectBox.LeftOffset + ele->Layout.RectBox.RightOffset
							cw += ele->Layout.w
							ch += ele->Layout.RectBox.TopOffset + ele->Layout.RectBox.BottomOffset
							ch += ele->Layout.h
						Case XUI_LAYOUT_RULER_RATIO
							' 宽高用剩余空间比例表示
							cw += ele->Layout.RectBox.LeftOffset + ele->Layout.RectBox.RightOffset
							ch += ele->Layout.RectBox.TopOffset + ele->Layout.RectBox.BottomOffset
							If (LayoutMode = XUI_LAYOUT_L2R) Or (LayoutMode = XUI_LAYOUT_R2L) Then
								ar += ele->Layout.w
							EndIf
							If (LayoutMode = XUI_LAYOUT_T2B) Or (LayoutMode = XUI_LAYOUT_B2T) Then
								ar += ele->Layout.h
							EndIf
						Case XUI_LAYOUT_RULER_COORD
							' 打破布局的元素，不进行计算 [强制浮动布局]
					End Select
				EndIf
			Next
			' 计算剩余空间
			If (LayoutMode = XUI_LAYOUT_L2R) Or (LayoutMode = XUI_LAYOUT_R2L) Then
				rs = Layout.Rect.w - cw
			EndIf
			If (LayoutMode = XUI_LAYOUT_T2B) Or (LayoutMode = XUI_LAYOUT_B2T) Then
				rs = Layout.Rect.h - ch
			EndIf
			' 第三个循环，计算每个元素的坐标和大小
			Dim px As Integer = 0
			Dim py As Integer = 0
			For i As Integer = 1 To c
				Dim ele As xui.Element Ptr
				ele = *Cast(xui.Element Ptr Ptr, Childs.GetPtrStruct(i))
				If ele->Visible Then
					Select Case ele->Layout.Ruler
						Case XUI_LAYOUT_RULER_PIXEL
							' 宽高用像素表示
							ele->Layout.Rect.w = ele->Layout.w
							ele->Layout.Rect.h = ele->Layout.h
							ele->Layout.Rect.x = ele->Layout.RectBox.LeftOffset + px
							ele->Layout.Rect.y = ele->Layout.RectBox.TopOffset + py
							ele->Layout.ScreenCoord.x = ele->Layout.Rect.x + Layout.ScreenCoord.x
							ele->Layout.ScreenCoord.y = ele->Layout.Rect.y + Layout.ScreenCoord.y
							If (LayoutMode = XUI_LAYOUT_L2R) Or (LayoutMode = XUI_LAYOUT_R2L) Then
								px += ele->Layout.RectBox.LeftOffset + ele->Layout.Rect.w + ele->Layout.RectBox.RightOffset
							EndIf
							If (LayoutMode = XUI_LAYOUT_T2B) Or (LayoutMode = XUI_LAYOUT_B2T) Then
								py += ele->Layout.RectBox.TopOffset + ele->Layout.Rect.h + ele->Layout.RectBox.BottomOffset
							EndIf
						Case XUI_LAYOUT_RULER_RATIO
							' 宽高用剩余空间比例表示
							ele->Layout.Rect.x = ele->Layout.RectBox.LeftOffset + px
							ele->Layout.Rect.y = ele->Layout.RectBox.TopOffset + py
							ele->Layout.ScreenCoord.x = ele->Layout.Rect.x + Layout.ScreenCoord.x
							ele->Layout.ScreenCoord.y = ele->Layout.Rect.y + Layout.ScreenCoord.y
							If (LayoutMode = XUI_LAYOUT_L2R) Or (LayoutMode = XUI_LAYOUT_R2L) Then
								ele->Layout.Rect.w = rs / ar * ele->Layout.w
								ele->Layout.Rect.h = Layout.Rect.h - ele->Layout.RectBox.TopOffset - ele->Layout.RectBox.BottomOffset
								px += ele->Layout.RectBox.LeftOffset + ele->Layout.Rect.w + ele->Layout.RectBox.RightOffset
							EndIf
							If (LayoutMode = XUI_LAYOUT_T2B) Or (LayoutMode = XUI_LAYOUT_B2T) Then
								ele->Layout.Rect.w = Layout.Rect.w - ele->Layout.RectBox.LeftOffset - ele->Layout.RectBox.RightOffset
								ele->Layout.Rect.h = rs / ar * ele->Layout.h
								py += ele->Layout.RectBox.TopOffset + ele->Layout.Rect.h + ele->Layout.RectBox.BottomOffset
							EndIf
						Case XUI_LAYOUT_RULER_COORD
							' 打破布局的元素，不进行计算 [强制浮动布局]
							ele->Layout.ScreenCoord.x = ele->Layout.Rect.x + Layout.ScreenCoord.x
							ele->Layout.ScreenCoord.y = ele->Layout.Rect.y + Layout.ScreenCoord.y
					End Select
				EndIf
				' 让子元素也应用布局
				ele->LayoutApply()
			Next
		EndIf
		Image->Create(Layout.Rect.w, Layout.Rect.h)
		NeedRedraw = -1
	End Sub
	
	' 画出元素
	Sub Element.Draw(sf As xge.Surface Ptr, px As Integer = 0, py As Integer = 0) XGE_EXPORT_OBJ
		Image->Clear()
		If ClassEvent.OnDraw Then
			ClassEvent.OnDraw(@This)
		EndIf
		If ClassEvent.OnUserDraw Then
			ClassEvent.OnUserDraw(@This)
		EndIf
		' 画出子元素
		Dim c As Integer = Childs.StructCount
		For i As Integer = 1 To c
			Dim ele As xui.Element Ptr
			ele = *Cast(xui.Element Ptr Ptr, Childs.GetPtrStruct(i))
			If ele->Visible Then
				ele->Draw(Image, 0, 0)
			EndIf
		Next
		' 调试模式画参考线
		If DrawRange Then
			DrawDebug()
		EndIf
		' 画到画布上
		Image->Draw(px + Layout.Rect.x, py + Layout.Rect.y, sf)
	End Sub
	
	' 画出元素的参考线
	Sub Element.DrawDebug() XGE_EXPORT_OBJ
		If Image Then
			xge.shape.Rect(0, 0, Layout.Rect.w - 1, Layout.Rect.h - 1, &HFF00FF00, Image)
			xge.Text.DrawRectA(Image, 0, 0, Layout.Rect.w - 1, Layout.Rect.h - 1, Identifier & " [" & Layout.ScreenCoord.x & "," & Layout.ScreenCoord.y & "]", &HFF00FF00)
		EndIf
	End Sub
	
	' 消息处理器
	Function Element.EventLink(msg As Integer, param As Integer, eve As xge_event Ptr) As Integer XGE_EXPORT_OBJ
		' 处理子控件的消息
		Dim c As Integer = Childs.StructCount
		For i As Integer = 1 To c
			Dim ele As xui.Element Ptr
			ele = *Cast(xui.Element Ptr Ptr, Childs.GetPtrStruct(i))
			If ele->Visible Then
				' 映射鼠标坐标
				Dim uieve As XGE_EVENT = *eve
				uieve.x = uieve.x - ele->Layout.Rect.x
				uieve.y = uieve.y - ele->Layout.Rect.y
				' 判断鼠标是否在元素内
				If (uieve.x >= 0) And (uieve.y >= 0) Then
					If (uieve.x < ele->Layout.Rect.w) And (uieve.y < ele->Layout.Rect.h) Then
						' 转发事件到子控件
						If ele->EventLink(msg, param, @uieve) Then
							Return -1
						EndIf
					EndIf
				EndIf
			EndIf
		Next
		' 处理控件本身的消息
		Select Case msg
			Case XGE_MSG_MOUSE_MOVE			' 鼠标移动
				' 鼠标下的元素将成为热点元素
				If xge_xui_element_hot <> @This Then
					If ClassEvent.OnMouseEnter Then
						ClassEvent.OnMouseEnter(@This)
						xge_xui_element_hot = @This
					EndIf
				EndIf
				' 处理移动事件
				If ClassEvent.OnMouseMove Then
					Return ClassEvent.OnMouseMove(@This, eve->x, eve->y)
				EndIf
			Case XGE_MSG_MOUSE_DOWN			' 鼠标按下
				If ClassEvent.OnMouseDown Then
					Return ClassEvent.OnMouseDown(@This, eve->x, eve->y, eve->button)
				EndIf
			Case XGE_MSG_MOUSE_UP			' 鼠标弹起
				If ClassEvent.OnMouseUp Then
					Return ClassEvent.OnMouseUp(@This, eve->x, eve->y, eve->button)
				EndIf
			Case XGE_MSG_MOUSE_CLICK		' 鼠标单击
				If ClassEvent.OnMouseClick Then
					Return ClassEvent.OnMouseClick(@This, eve->x, eve->y, eve->button)
				EndIf
			Case XGE_MSG_MOUSE_DCLICK		' 鼠标双击
				If ClassEvent.OnMouseDoubleClick Then
					Return ClassEvent.OnMouseDoubleClick(@This, eve->x, eve->y, eve->button)
				EndIf
		End Select
		Return 0
	End Function
	
	
	
End Namespace



End Extern


