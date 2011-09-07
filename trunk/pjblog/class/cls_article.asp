﻿<%
'==================================
'  日志类文件
'    更新时间: 2006-1-22
'==================================

'SQL="SELECT top 1 log_ID,log_CateID,log_title,Log_IsShow,log_ViewNums,log_Author,log_comorder,log_DisComment,log_Content,log_PostTime,log_edittype,log_ubbFlags,log_CommNums,log_QuoteNums,log_weather,log_level,log_Modify,log_FromUrl,log_From,log_tag FROM blog_Content WHERE log_ID="&id&" and log_IsDraft=false"
'row序号:          0     ,1         ,2         ,3        ,4           ,5         ,6           ,7             ,8          ,9           ,10          ,11          ,12           ,13         ,14         ,15       ,16        ,17         ,18       ,19

'*******************************************
'  显示日志内容
'*******************************************

Sub updateViewNums(logID, vNums)
    If blog_postFile<1 Then Exit Sub
    Dim LoadArticle, splitStr, getA, i, tempStr
    splitStr = "<"&"%ST(A)%"&">"
    tempStr = ""
    LoadArticle = LoadFromFile("cache/"&LogID&".asp")
    If LoadArticle(0) = 0 Then
        getA = Split(LoadArticle(1), splitStr)
        getA(2) = vNums
        For i = 1 To UBound(getA)
            tempStr = tempStr&splitStr&getA(i)
        Next
        Call SaveToFile (tempStr, "cache/" & LogID & ".asp")
	    if memoryCache = true then
			Application.Lock
			Application(CookieName&"_introCache_"&LogID) = tempStr
			Application.UnLock
		end if
    End If
End Sub


Sub ShowArticle(LogID)
    If (log_ViewArr(5, 0) = memName And log_ViewArr(3, 0) = False) Or stat_Admin Or log_ViewArr(3, 0) = True or Trim(log_ViewArr(20, 0)) <> "" Then
    Else
        showmsg "错误信息", "该日志为私密日志，没有权限查看该日志！<br/><a href=""default.asp"">单击返回</a>", "ErrorIcon", ""
    End If
    If (Not getCate.cate_Secret) Or (log_ViewArr(5, 0) = memName And getCate.cate_Secret) Or stat_Admin Or (getCate.cate_Secret And stat_ShowHiddenCate) Then
    Else
        showmsg "错误信息", "该日志分类为私密类型，无法查看该日志！<br/><a href=""default.asp"">单击返回</a>", "ErrorIcon", ""
    End If

    If log_ViewArr(6, 0) Then comDesc = "Desc" Else comDesc = "Asc" End If

    '是否有权限查看日记
    Dim CanRead,CheckReadPW
    CanRead = False
    CheckReadPW = md5(Trim(Request.form("PW")))
    
    If CheckReadPW = "D41D8CD98F00B204E9800998ECF8427E" Then '空白的md5
    	CheckReadPW = Session("ReadPassWord_"&LogID)
    Else
    	Session("ReadPassWord_"&LogID) = CheckReadPW
    End If

    If IsNull(Session("CheckOutErr_"&LogID)) Or IsEmpty(Session("CheckOutErr_"&LogID)) Then Session("CheckOutErr_"&LogID) = 0
    If stat_Admin = True Then CanRead = True
    If log_ViewArr(3, 0) Then CanRead = True
    If log_ViewArr(3, 0) = False And log_ViewArr(5, 0) = memName Then CanRead = True
    If Trim(log_ViewArr(20,0)) = CheckReadPW Then CanRead = True

    '从文件读取日志
    If Trim(log_ViewArr(20, 0)) = "" and blog_postFile>0 and log_ViewArr(26, 0) = False Then
        Dim LoadArticle, TempStr, TempArticle
        LoadArticle = LoadFromFile("post/"&LogID&".asp")

        If LoadArticle(0) = 0 Then
            TempArticle = LoadArticle(1)
            TempStr = ""
            If stat_EditAll Or (stat_Edit And memName = log_ViewArr(5, 0)) Then
                TempStr = TempStr&"<a href=""blogedit.asp?id="&LogID&""" title=""编辑该日志"" accesskey=""E""><img src=""images/icon_edit.gif"" alt="""" border=""0"" style=""margin-bottom:-2px""/></a> "
            End If

            If stat_DelAll Or (stat_Del And memName = log_ViewArr(5, 0)) Then
                TempStr = TempStr&"<a href=""blogedit.asp?action=del&amp;id="&LogID&""" onclick=""if (!window.confirm('是否要删除该日志')) return false"" title=""删除该日志"" accesskey=""K""><img src=""images/icon_del.gif"" alt="""" border=""0"" style=""margin-bottom:-2px""/></a>"
            End If

            TempArticle = Replace(TempArticle, "<"&"%ST(A)%"&">", "")
            TempArticle = Replace(TempArticle, "<$EditAndDel$>", TempStr)
            TempArticle = Replace(TempArticle, "<$log_ViewNums$>", log_ViewArr(4, 0))

            response.Write TempArticle
            ShowComm LogID, comDesc, log_ViewArr(7, 0), False, log_ViewArr(3, 0), log_ViewArr(23,0), CanRead,  false
            Call updateViewNums(id, log_ViewArr(4, 0))
        Else
            response.Write "读取日志出错.<br/>" & LoadArticle(0) & " : " & LoadArticle(1)
        End If
        Exit Sub
    End If

    '从数据库读取日志
    'on error resume Next
    Set preLog = Conn.Execute("SELECT TOP 1 T.log_Title,T.log_ID FROM blog_Content As T,blog_Category As C WHERE T.log_PostTime<#"&DateToStr(log_ViewArr(9, 0), "Y-m-d H:I:S")&"# and T.log_CateID=C.cate_ID and (T.log_IsShow=true or T.log_Readpw<>'') and C.cate_Secret=False ORDER BY T.log_PostTime DESC")
    Set nextLog = Conn.Execute("SELECT TOP 1 T.log_Title,T.log_ID FROM blog_Content As T,blog_Category As C WHERE T.log_PostTime>#"&DateToStr(log_ViewArr(9, 0), "Y-m-d H:I:S")&"# and T.log_CateID=C.cate_ID and (T.log_IsShow=true or T.log_Readpw<>'') and C.cate_Secret=False ORDER BY T.log_PostTime ASC")
    SQLQueryNums = SQLQueryNums + 2

%>
					   <div id="Content_ContentList" class="content-width"><a name="body" accesskey="B" href="#body"></a>
					   <div class="pageContent">
 						   <img src="<%=getCate.cate_icon%>" style="margin:0px 2px -4px 0px" alt=""/> <strong><a href="default.asp?cateID=<%=log_ViewArr(1,0)%>" title="查看所有【<%=getCate.cate_Name%>】的日志"><%=getCate.cate_Name%></a></strong> <a href="feed.asp?cateID=<%=log_ViewArr(1,0)%>" target="_blank" title="订阅所有【<%=getCate.cate_Name%>】的日志" accesskey="O"><img border="0" src="images/rss.png" alt="订阅所有【<%=getCate.cate_Name%>】的日志" style="margin-bottom:-1px"/></a>
					   </div>
					   <div class="Content">
					   <div class="Content-top"><div class="ContentLeft"></div><div class="ContentRight"></div>
					     <h1 class="ContentTitle"><strong>
							 <%If CanRead Then%>
							 <%=HtmlEncode(log_ViewArr(2, 0))%>
							 <% Else %>
							 <%If log_ViewArr(22, 0) = False then%><%=HtmlEncode(log_ViewArr(2, 0))%><%ElseIf Trim(log_ViewArr(20, 0)) <> "" Then%>[加密日志]<%Else%>[私密日志]<%End If%>
							 <% End If %>
							 </strong> 
							 <%if log_ViewArr(3, 0)=False or getCate.cate_Secret then%>
							 <%If Trim(log_ViewArr(20, 0)) <> "" Then%><img src="images/icon_lock2.gif" style="margin:0px 0px -3px 2px;" alt="加密日志" /><%Else%><img src="images/icon_lock1.gif" style="margin:0px 0px -3px 2px;" alt="私密日志" /><%End If%>
							 <%end if%>
							 </h1>
					     <h2 class="ContentAuthor">作者:<%=log_ViewArr(5,0)%> 日期:<%=DateToStr(log_ViewArr(9,0),"Y-m-d")%></h2>
					   </div>
					    <div class="Content-Info">
						  <div class="InfoOther">字体大小: <a href="javascript:SetFont('12px')" accesskey="1">小</a> <a href="javascript:SetFont('14px')" accesskey="2">中</a> <a href="javascript:SetFont('16px')" accesskey="3">大</a></div>
						  <div class="InfoAuthor"><img src="images/weather/hn2_<%=log_ViewArr(14,0)%>.gif" style="margin:0px 2px -6px 0px" alt=""/><img src="images/weather/hn2_t_<%=log_ViewArr(14,0)%>.gif" alt=""/> <img src="images/<%=log_ViewArr(15,0)%>.gif" style="margin:0px 2px -1px 0px" alt=""/>
						    <%if stat_EditAll or (stat_Edit and log_ViewArr(5,0)=memName) then %>　<a href="blogedit.asp?id=<%=log_ViewArr(0,0)%>" title="编辑该日志" accesskey="E"><img src="images/icon_edit.gif" alt="" border="0" style="margin-bottom:-2px"/></a><%end if%>
					        <%if stat_DelAll or (stat_Del and log_ViewArr(5,0)=memName)  then %>　<a href="blogedit.asp?action=del&amp;id=<%=log_ViewArr(0,0)%>" onclick="if (!window.confirm('是否要删除该日志')) return false" accesskey="K"><img src="images/icon_del.gif" alt="" border="0" style="margin-bottom:-2px"/></a><%end if%>
						  </div>
						</div>
					  <div id="logPanel" class="Content-body">
						<%If CanRead Then '密码访问
							keyword = CheckStr(Request.QueryString("keyword"))
							If log_ViewArr(10, 0) = 1 Then
							    response.Write (highlight(UnCheckStr(UBBCode(HtmlEncode(log_ViewArr(8, 0)), Mid(log_ViewArr(11, 0), 1, 1), Mid(log_ViewArr(11, 0), 2, 1), Mid(log_ViewArr(11, 0), 3, 1), Mid(log_ViewArr(11, 0), 4, 1), Mid(log_ViewArr(11, 0), 5, 1))), keyword))
							Else
							    response.Write (highlight(UnCheckStr(log_ViewArr(8, 0)), keyword))
							End If
						Else
						%>
						<div>
							<h5 class="tips"><img alt="加密日志" style="margin: 0px 0px -3px 2px;" src="images/icon_lock2.gif"/> 该日志是加密日志，需要输入正确密码才可以查看！</h5>
							<div class="tips_body">
								<%if Session("CheckOutErr_"&LogID) >=2 Then '超出范围%>
									<div class="error">抱歉，您输入的验证次数已超过最大的次数，日志暂时锁定！</div>
								<%
								Else
									dim pwTips
									pwTips = Trim(log_ViewArr(21,0))
								%>
									<form id="CheckRead" name="CheckRead" method="post" action="">
										<%If Trim(Request.Form("do")) = "CheckOut" Then
											Session("CheckOutErr_"&LogID) = Session("CheckOutErr_"&LogID) + 1
											response.write "<div class=""error"">密码错误。您还有 " & 3 - Session("CheckOutErr_"&LogID) & " 次密码验证的机会。</div>"
										 End If%>
										<input name="do" type="hidden" value="CheckOut" />
										<label for="pw"><input name="pw" type="password" id="pw" size="15" class="input"/></label>
										<input type="image" name="Submit" value="确　定" src="images/unlock.gif" style="margin-bottom:-8px;*margin-bottom:-6px"/> <%if pwTips="" then%>『暂无提示』<%else%><a href="javascript:;" onclick="$('hints').style.display=$('hints').style.display=='none'?'':'none';" title="显示/隐藏密码提示">密码提示</a><%end if%>
										<div id="hints" class="hints" style="display:none">
											<%=pwTips%>
										</div>
									</form>
								<%end if%>
							</div>
						</div>
					<%
					End If	
					%>
					   <br/><br/>
					   </div>
					   <div class="Content-body">
					    <%
					    if len(log_ViewArr(16,0))>0 then response.write ("<div class=""Modify"">"&log_ViewArr(16,0)&"</div>")
If Not preLog.EOF Then
    	if blog_postFile = 2 then
    		urlLink = caload(preLog("log_ID"))
    	else 
    		urlLink = "?id="&preLog("log_ID")
    	end if
    response.Write ("<img border=""0"" src=""images/Cprevious.gif"" alt=""""/><strong>上一篇:</strong> <a href="""&urlLink&""" accesskey="","">"&preLog("log_Title")&"</a><br/>")
Else
    response.Write ("<img border=""0"" src=""images/Cprevious1.gif""/><strong>上一篇:</strong> <i>这是最早一篇日志</i><br/>")
End If
If Not nextLog.EOF Then
    	if blog_postFile = 2 then
    		urlLink = caload(nextLog("log_ID"))
    	else 
    		urlLink = "?id="&nextLog("log_ID")
    	end if
    response.Write ("<img border=""0"" src=""images/Cnext.gif"" alt=""""/><strong>下一篇:</strong> <a href="""&urlLink&""" accesskey=""."">"&nextLog("log_Title")&"</a><br/>")
Else
    response.Write ("<img border=""0"" src=""images/Cnext1.gif"" alt=""""/><strong>下一篇:</strong> <i>这是最新一篇日志</i><br/>")
End If
preLog.Close
nextLog.Close
Set preLog = Nothing
Set nextLog = Nothing
%>
						<img src="images/From.gif" style="margin:4px 2px -4px 0px" alt=""/><strong>文章来自:</strong> <a href="<%=log_ViewArr(17,0)%>" target="_blank"><%=log_ViewArr(18,0)%></a><br/>
						<img src="images/icon_trackback.gif" style="margin:4px 2px -4px 0px" alt=""/><strong>引用通告:</strong> <a href="<%="trackback.asp?tbID="&id&"&amp;action=view"%>" target="_blank">查看所有引用</a> | <a href="javascript:;" title="获得引用文章的链接" onclick="getTrackbackURL(<%=id%>)">我要引用此文章</a><br/>
					   	<%Dim getTag
					   	Set getTag = New tag
					   	%>
						 <img src="images/tag.gif" style="margin:4px 2px -4px 0px" alt=""/><strong>Tags:</strong> <%=getTag.filterHTML(log_ViewArr(19,0))%><br/>
						 <img src="images/notify.gif" style="margin:4px 2px -4px 0px" alt=""/><strong>相关日志:</strong>
						 <div class="Content-body" id="related_tag" style="margin-left:25px"></div>
						 <script language="javascript" type="text/javascript">Related(<%=LogID%>, 1, 1, 'related_tag');</script>
					   </div>
					   <div class="Content-bottom"><div class="ContentBLeft"></div><div class="ContentBRight"></div>评论: <%=log_ViewArr(12,0)%> | 引用: <%=log_ViewArr(13,0)%> | 查看次数: <%=log_ViewArr(4,0)%>
					   </div></div>
					   </div>
<%Set getTag = Nothing
ShowComm LogID, comDesc, log_ViewArr(7, 0), False, log_ViewArr(3, 0), log_ViewArr(23,0), CanRead, False  '显示评论内容
End Sub


'*******************************************
'  显示日志评论内容
'*******************************************

Function ShowComm(ByVal LogID,ByVal comDesc, ByVal DisComment, ByVal forStatic, ByVal logShow, ByVal logPwcomm, ByVal CanRead, ByVal forStaticComment)
	ShowComm = ""
    ShowComm = ShowComm&"<a name=""comm_top"" href=""#comm_top"" accesskey=""C""></a>"
    
    Dim blog_Comment, Pcount, comm_Num, blog_CommID, blog_CommAuthor, blog_CommContent, Url_Add, commArr, commArrLen, BaseUrl, aName, aEvent, outPutCommentCount, GravatarImg, NewGravatar, blog_CommentEmail, blog_CommentWebSite, blog_CommentEmailImg, blog_CommentWebSiteImg
    Set blog_Comment = Server.CreateObject("Adodb.RecordSet")
    
    Pcount = 0
    BaseUrl = ""
    aEvent = ""
	outPutCommentCount = ""
    
   ' 带 trackback 的查询
   ' SQL = "SELECT comm_ID,comm_Content,comm_Author,comm_PostTime,comm_DisSM,comm_DisUBB,comm_DisIMG,comm_AutoURL,comm_PostIP,comm_AutoKEY FROM blog_Comment WHERE blog_ID="&LogID&" UNION ALL SELECT 0,tb_Intro,tb_Title,tb_PostTime,tb_URL,tb_Site,tb_ID,0,'127.0.0.1',0 FROM blog_Trackback WHERE blog_ID="&LogID&" ORDER BY comm_PostTime "&comDesc
  
   ' 不带 trackback 的查询，速度较快
   SQL = "SELECT comm_ID,comm_Content,comm_Author,comm_PostTime,comm_DisSM,comm_DisUBB,comm_DisIMG,comm_AutoURL,comm_PostIP,comm_AutoKEY,comm_IsAudit,comm_Email,comm_WebSite FROM blog_Comment WHERE blog_ID="&LogID&" ORDER BY comm_PostTime "&comDesc

    blog_Comment.Open SQL, Conn, 1, 1
    SQLQueryNums = SQLQueryNums + 1
    If (blog_Comment.EOF And blog_Comment.BOF) or (logPwcomm = True and CanRead = False) Then
    
    Else
        blog_Comment.PageSize = blogcommpage
        blog_Comment.AbsolutePage = CurPage
        comm_Num = blog_Comment.RecordCount

        commArr = blog_Comment.GetRows(comm_Num)
        blog_Comment.Close
        Set blog_Comment = Nothing
        commArrLen = UBound(commArr, 2)

        Url_Add = "?id="&LogID&"&"
        aName = "#comm_top"

        If blog_postFile = 2 and logShow then '静态页面使用#方式来切换
        	BaseUrl = caload(LogID)
        	Url_Add="#"
        	aName = ""
        	aEvent = "onclick=""openCommentPage(this)"""
        End If 

		'顶部翻页
  	   ShowComm = ShowComm&"<div class=""pageContent"">"&MultiPage(comm_Num,blogcommpage,CurPage,Url_Add,aName,"float:right", BaseUrl,aEvent)&"</div>"

	   '显示评论
		Do Until Pcount = commArrLen + 1 Or Pcount = blogcommpage
		    blog_CommID = commArr(0, Pcount)
		    blog_CommAuthor = commArr(2, Pcount)
		    blog_CommContent = commArr(1, Pcount)
			If blog_postFile = 2 Then
				outPutCommentCount = outPutCommentCount & blog_CommID & "|$|"
			End If
			If blog_GravatarOpen Then
			' Gravatar 头像基本设置
				Set NewGravatar = new Gravatar
				If Len(commArr(11, Pcount)) > 0 Then
					NewGravatar.Gravatar_EmailMd5 = Trim(MD5(Trim(commArr(11, Pcount))))
					GravatarImg = lcase(NewGravatar.outPut())
				Else
					NewGravatar.Gravatar_EmailMd5 = ""
					GravatarImg = "images/gravatar.gif"
				End If
				Set NewGravatar = nothing
			End If
     		ShowComm = ShowComm&"<div class=""comment"" "
			
			If blog_GravatarOpen Then
				ShowComm = ShowComm&"style=""text-align:right"" "
			End If
			
			ShowComm = ShowComm&">"
			
			If blog_GravatarOpen Then
				ShowComm = ShowComm&"<div class=""commentleft Gravatar"" style=""float:left"" id=""Gravatar_"&blog_CommID&""">"
					ShowComm = ShowComm&"<img src="""&GravatarImg&""" alt="""&blog_CommAuthor&""" border=""0"" />"
				ShowComm = ShowComm&"</div><div class=""commentright"" style=""text-align:left"">"
			End If
			
			blog_CommentEmail = commArr(11, Pcount)
			blog_CommentWebSite = commArr(12, Pcount)
			
			If IsBlank(blog_CommentEmail) Then 
				blog_CommentEmailImg = "<img src=""images/noCommentEmail.gif"" border=""0"">" 
			Else 
				blog_CommentEmailImg = "<a href=""mailto:"&blog_CommentEmail&"""><img src=""images/CommentEmail.gif"" border=""0"" alt=""Mail To:"&blog_CommentEmail&"""></a>"
			End If
			If IsBlank(blog_CommentWebSite) Then 
				blog_CommentWebSiteImg = "<img src=""images/nositeurl.gif"" border=""0"">" 
			Else 
				blog_CommentWebSiteImg = "<a href="""&blog_CommentWebSite&""" target=""_blank""><img src=""images/siteurl.gif"" border=""0"" alt=""访问 "&blog_CommentWebSite&"""></a>"
			End If
			
			ShowComm = ShowComm&"<div class=""commenttop"">"
     		ShowComm = ShowComm&"<a name=""comm_"&blog_CommID&""" href=""javascript:addQuote('"&blog_CommAuthor&"','commcontent_"&blog_CommID&"')""><img border=""0"" src=""images/icon_quote.gif"" alt="""" style=""margin:0px 4px -3px 0px""/></a>"
     		ShowComm = ShowComm&"<a href=""member.asp?action=view&memName="&Server.URLEncode(blog_CommAuthor)&"""><strong>"&blog_CommAuthor&"</strong></a>"
     		ShowComm = ShowComm&"<span class=""commentinfo"">["&DateToStr(commArr(3,Pcount),"Y-m-d H:I A")&" | "&blog_CommentWebSiteImg&"<span class=""ownerClassComment""> | "&blog_CommentEmailImg&" | "&commArr(8,Pcount)&" | <a href=""blogcomm.asp?action=del&amp;commID="&blog_CommID&""" onclick=""return delCommentConfirm()""><img src=""images/del1.gif"" alt=""del"" border=""0""/></a>"
			'' 评论审核按钮部分
			If blog_AuditOpen Then
				'If stat_Admin Then
					If commArr(10,Pcount) Then
						ShowComm = ShowComm&" | <a href=""javascript:void(0)"" onclick=""IndexAudit("&blog_CommID&", 1, this, " & LogID & ");"">取消审核</a>"
					Else
						ShowComm = ShowComm&" | <a href=""javascript:void(0)"" onclick=""IndexAudit("&blog_CommID&", 0, this, " & LogID & ");"">通过审核</a>"
					End If
				'End If
			End If
			ShowComm = ShowComm&" | <span style=""cursor:pointer"" onclick=""replyMsg("&LogID&","&blog_CommID&","&commArr(4,Pcount)&","&commArr(7,Pcount)&","&commArr(9,Pcount)&")""><img src=""images/reply.gif"" alt=""回复"" style=""margin-bottom:-3px;""/>回复</span>"
			ShowComm = ShowComm&"</span>]</span></div>"
		
			'删除按钮
		'	if stat_Admin=true or (stat_CommentDel=true and memName=blog_CommAuthor) then 
		'		response.write (" | <a href=""blogcomm.asp?action=del&amp;commID="&blog_CommID&""" onclick=""if (!window.confirm('是否删除该评论?')) {return false}""><img src=""images/del1.gif"" alt=""删除该评论"" border=""0""/></a>") 
		'	end if
			
     		'ShowComm = ShowComm&"<div class=""comment""><div class=""commenttop"">"
			'评论内容
			ShowComm = ShowComm&"<div class=""commentcontent"" id=""commcontent_"&blog_CommID&""">"
			'评论审核部分
			If blog_AuditOpen Then
				If blog_postFile = 2 Then '  区分动静态
					 If forStaticComment Then '区分静态下的评论
						If stat_Admin Or memName=blog_CommAuthor Then '  判断权限
							If commArr(10,Pcount) Then
								ShowComm = ShowComm&UBBCode(HtmlEncode(blog_CommContent),commArr(4,Pcount),blog_commUBB,blog_commIMG,commArr(7,Pcount),commArr(9,Pcount))
							Else
								ShowComm = ShowComm&"<span class=""CommentCheck"">[此评论正在审核中,内容如下：]</span><br/>"&UBBCode(HtmlEncode(blog_CommContent),commArr(4,Pcount),blog_commUBB,blog_commIMG,commArr(7,Pcount),commArr(9,Pcount))
							End If
						Else
							If commArr(10,Pcount) Then	
								ShowComm = ShowComm&UBBCode(HtmlEncode(blog_CommContent),commArr(4,Pcount),blog_commUBB,blog_commIMG,commArr(7,Pcount),commArr(9,Pcount))
							Else
								ShowComm = ShowComm&"<span class=""CommentCheck"">[此评论正在审核中,只有博主及评论作者可见]</span>"
							End If
						End If
					Else
						ShowComm = ShowComm & "<span class=""CommentCheck"">[正在加载评论信息,请稍候...]</span>"
					End If
				Else
					If stat_Admin Or memName=blog_CommAuthor Then '  判断权限
						If commArr(10,Pcount) Then
							ShowComm = ShowComm&UBBCode(HtmlEncode(blog_CommContent),commArr(4,Pcount),blog_commUBB,blog_commIMG,commArr(7,Pcount),commArr(9,Pcount))
						Else
							ShowComm = ShowComm&"<span class=""CommentCheck"">[此评论正在审核中,内容如下：]</span><br/>"&UBBCode(HtmlEncode(blog_CommContent),commArr(4,Pcount),blog_commUBB,blog_commIMG,commArr(7,Pcount),commArr(9,Pcount))
						End If
					Else
						If commArr(10,Pcount) Then	
							ShowComm = ShowComm&UBBCode(HtmlEncode(blog_CommContent),commArr(4,Pcount),blog_commUBB,blog_commIMG,commArr(7,Pcount),commArr(9,Pcount))
						Else
							ShowComm = ShowComm&"<span class=""CommentCheck"">[此评论正在审核中,只有博主及评论作者可见]</span>"
						End If
					End If
				End If
			Else
				ShowComm = ShowComm&UBBCode(HtmlEncode(blog_CommContent),commArr(4,Pcount),blog_commUBB,blog_commIMG,commArr(7,Pcount),commArr(9,Pcount))
			End If
			
			ShowComm = ShowComm&"</div>"
			
			If blog_GravatarOpen Then
				ShowComm = ShowComm&"</div>"
			End If
			
			ShowComm = ShowComm&"</div>"
			Pcount = Pcount + 1
		Loop
			If blog_postFile = 2 Then
				outPutCommentCount = outPutCommentCount & "end"
				ShowComm = ShowComm&"<script language='javascript' type='text/javascript'>ReadArticleComentByCommentID('"&outPutCommentCount&"');</script>"
			End If
		'底部的翻页
       ShowComm = ShowComm&"<div class=""pageContent"">"&MultiPage(comm_Num,blogcommpage,CurPage,Url_Add,aName,"float:right" ,BaseUrl,aEvent)&"</div>"
	End If
	
	If not forStatic Then
		Response.write ShowComm
		'输出发表评论框
		Call showCommentPost(logID,DisComment,logPwcomm,CanRead)
	End IF
End Function

'===============
' 输出发表评论框
'===============
Sub ShowCommentPost(ByVal logID, ByVal DisComment, ByVal logPwcomm, ByVal CanRead)
	If DisComment Then 
		Exit Sub
	End IF
	
%>
<div id="MsgContent" style="width:94%;"><div id="MsgHead">发表评论</div><div id="MsgBody">
<%
		If Not stat_CommentAdd Then
		    response.Write ("你没有权限发表评论！")
		    response.Write ("</div></div>")
		    Exit Sub
		End If
		If logPwcomm = True and CanRead = False Then
		    response.Write ("该日志需要输入正确密码方可发表和查看评论！")
		    response.Write ("</div></div>")
		    Exit Sub
		End If
		
		%>
		      <script type="text/javascript">
		      		function checkCommentPost(){
		      			if (!CheckPost) return false
						// 备用方法
		      			return true
		      		}
		      </script>
              <%
			  Dim Ts, Ts_UserName, Ts_Content, Ts_True, Ts_Email, Ts_WebSite
			  ' ------------------------------
			  ' 初始化变量
			  ' ------------------------------
			  Ts_UserName = ""
			  Ts_Email = ""
			  Ts_WebSite = ""
			  If Len(Request.Cookies(CookieName)("Guest")) > 0 Then
				  Set Ts = toJson(Request.Cookies(CookieName)("Guest"))
				  Ts_True = Ts.record ' 获得cookie中保存的布尔变量
				  ' ------------------------------
				  ' 变量赋值
				  ' ------------------------------
				  If Ts_True Then
					Ts_UserName = Ts.username
					Ts_Email = Ts.useremail
					Ts_WebSite = Ts.userwebsite
				  End If
			  End If
			  %>
		      <form name="frm" action="blogcomm.asp" method="post" onsubmit="return checkCommentPost()" style="margin:0px;">	  
			  <table width="100%" cellpadding="0" cellspacing="0">	  
			  <tr><td align="right" width="70"><strong>昵　称:</strong></td><td align="left" style="padding:3px;"><input name="username" type="text" size="18" class="userpass" maxlength="24" <%
			  If not memName=empty then
			  	response.write ("value="""&memName&""" readonly=""readonly""")
			  Else
			  	If Ts_True = true Then
					response.write ("value="""&Ts_UserName&"""")
				End if
			  End if
			  %>/>
			  <%if memName=empty then%>
			  <label for="label8"><input name="log_GuestCanRemeberComment" type="checkbox" id="label8" value="1" id="e_GuestCanRemeberComment" checked="checked"/>记住我的信息</label>
			  <%else%> 您当前的权限:[<%=stat_title%>] <a href="login.asp?action=logout">[退出]</a>
			  <%end if%>
			  </td></tr>
		      <%if memName=empty then%>
		      <tr><td align="right" width="70"><strong>密　码:</strong></td><td align="left" style="padding:3px;"><input name="password" type="password" size="18" class="userpass" maxlength="24"/> 游客发言不需要密码.</td></tr>
              <tr><td align="right" width="70"><strong>邮　箱:</strong></td><td align="left" style="padding:3px;"><input name="Email" type="text" size="30" class="userpass" value="<%if Ts_True = true then response.write(Ts_Email) Else Response.Write("")%>" /> 邮件地址支持<a href="http://www.gravatar.com/site/signup/" title="没有Gravatar头像？在线申请吧..." target="_blank">Gravatar</a>头像,邮箱地址不会公开.</td></tr>
              <tr><td align="right" width="70"><strong>网　址:</strong></td><td align="left" style="padding:3px;"><input name="WebSite" type="text" size="30" class="userpass" value="<%if Ts_True = true then response.write(Ts_WebSite) Else Response.Write("")%>" onfocus="if (this.value.length >= 0 && this.value.substring(0, 7) != 'http://'){this.value = 'http://' + this.value}" onblur="if (this.value.length >= 0 && this.value.substring(0, 7) != 'http://'){this.value = 'http://' + this.value}else{if (this.value == 'http://'){this.value = ''}}" /> 输入网址便于回访.</td></tr>
              <%end if%>
			  <tr><td align="right" width="70" valign="top"><strong>内　容:</strong><br/>
			  </td><td style="padding:2px;">
			   <%
				UBB_TextArea_Height = "150px;"
				UBB_Tools_Items = "bold,italic,underline,deleteline"
				UBB_Tools_Items = UBB_Tools_Items&"||image,link,mail,quote,smiley"
				Response.write (UBBeditorCore("Message"))
				%>
			  </td></tr>
			  <%if (memName=empty or blog_validate=true) and stat_Admin=false then%><tr><td align="right" width="70">
              <strong>验证码:</strong></td><td align="left" style="padding:3px;"><input name="validate" type="text" size="4" class="userpass" maxlength="4" onFocus="get_checkcode();this.onfocus=null;" onKeyUp="ajaxcheckcode('isok_checkcode',this);"/> <span id="checkcode"><label style="cursor:pointer;" onClick="get_checkcode();">点击获取验证码</label></span> <span id="isok_checkcode"></span></td></tr><%end if%>
			  <tr><td align="right" width="70"><strong>选　项:</strong></td>
			  <td align="left" style="padding:3px;">
		             <label for="label5"><input name="log_DisSM" type="checkbox" id="label5" value="1" style="margin-top:-2px;"/> 禁止表情转换</label>
		             <label for="label6"><input name="log_DisURL" type="checkbox" id="label6" value="1" style="margin-top:-2px;"/> 禁止自动转换链接</label>
		             <label for="label7"><input name="log_DisKey" type="checkbox" id="label7" value="1" style="margin-top:-2px;"/> 禁止自动转换关键字</label>
			  </td></tr>
		          <tr>
		            <td colspan="2" align="center" style="padding:3px;">
					  <input name="logID" type="hidden" value="<%=LogID%>"/>
		              <input name="action" type="hidden" value="post"/>
					  <input name="submit2" type="submit" class="userbutton" value="发表评论" accesskey="S"/>
		              <input name="button" type="reset" class="userbutton" value="重写"/></td>
		          </tr>
		          <tr>
		            <td colspan="2" align="right" >
					 <%if memName=empty then%>
					 	虽然发表评论不用注册，但是为了保护您的发言权，建议您<a href="register.asp">注册帐号</a>.<br/>
					 <%end if%>
			  字数限制 <b><%=blog_commLength%> 字</b> |
			  UBB代码 <b><%if (blog_commUBB=0) then response.write ("开启") else response.write ("关闭") %></b> |
			  [img]标签 <b><%if (blog_commIMG=0) then response.write ("开启") else response.write ("关闭") %></b>
					</td>
		          </tr>		  
			  </table></form>
	<%response.Write ("</div></div>")
end Sub
%>