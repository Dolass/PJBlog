﻿<%'---- ASPCode For GuestBookForPJBlog ----%>
<%'---- ASPCode For GuestBookForPJBlogSubItem1 ----%>

<%
        function NewMessage(ByVal action)
             Dim blog_Message
             IF Not IsArray(Application(CookieName&"_blog_Message")) or action=2 Then
             	Dim book_Messages,book_Message
             	Set book_Messages=Conn.Execute("SELECT top 10 * FROM blog_book order by book_PostTime Desc")
             	SQLQueryNums=SQLQueryNums+1
             	TempVar=""
             	Do While Not book_Messages.EOF
             	    if book_Messages("book_HiddenReply") then
                        book_Message=book_Message&TempVar&book_Messages("book_ID")&"|,|"&book_Messages("book_Messager")&"|,|"&book_Messages("book_PostTime")&"|,|"&"[隐藏留言]"
             	     else
                        book_Message=book_Message&TempVar&book_Messages("book_ID")&"|,|"&book_Messages("book_Messager")&"|,|"&book_Messages("book_PostTime")&"|,|"&book_Messages("book_Content")
             	    end if
             		TempVar="|$|"
             		book_Messages.MoveNext
             	Loop
             	Set book_Messages=Nothing
             	blog_Message=Split(book_Message,"|$|")
             	Application.Lock
             	Application(CookieName&"_blog_Message")=blog_Message
             	Application.UnLock
             Else
             	blog_Message=Application(CookieName&"_blog_Message")
             End IF
             
             if action<>2 then
              dim Message_Items,Message_Item
             	For Each Message_Items IN blog_Message
             	 Message_Item=Split(Message_Items,"|,|")
             	 NewMessage=NewMessage&"<a class=""sideA"" href=""LoadMod.asp?plugins=GuestBookForPJBlog#book_"&Message_Item(0)&""" title="""&Message_Item(1)&" 于 "&Message_Item(2)&" 发表留言"&CHR(10)&CCEncode(CutStr(Message_Item(3),25))&""">"&CCEncode(CutStr(Message_Item(3),25))&"</a>"
             	Next
              end if
       end function
   
       '处理最新留言内容
        Dim Message_code
        if Session(CookieName&"_LastDo")="DelMessage" or Session(CookieName&"_LastDo")="AddMessage" then NewMessage(2)
    	Message_code=NewMessage(0)
        side_html_default=replace(side_html_default,"<$NewMsg$>",Message_code)
        side_html=replace(side_html,"<$NewMsg$>",Message_code)
    %>
     
