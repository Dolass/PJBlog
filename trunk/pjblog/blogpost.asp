﻿<!--#include file="commond.asp" -->
<!--#include file="header.asp" -->
<!--#include file="common/UBBconfig.asp" -->
<!--#include file="FCKeditor/fckeditor.asp" -->
<!--#include file="common/ModSet.asp" -->
<!--#include file="class/cls_logAction.asp" -->
<!--#include file="class/cls_article.asp" -->

<div id="Tbody">
  <div style="text-align:center;">
  <br/>
  <%
'==================================
'  发表日志页面
'    更新时间: 2006-1-22
'==================================
Dim preLog, nextLog
If ChkPost() Then
    If stat_AddAll<>True And stat_Add<>True Then
%>
      <div id="MsgContent" style="width:350px">
        <div id="MsgHead">出错信息</div>
        <div id="MsgBody">
  		 <div class="ErrorIcon"></div>
          <div class="MessageText"><b>您没有没有权限发表新日志!</b><br/>
          <a href="default.asp">单击返回首页</a><%if memName=Empty Then %> | <a href="login.asp">登录</a><%end if%>
  		 </div>
  	 </div>
  	</div>
  <%else%>
   <!--内容-->
   <%If Request.Form("action") = "post" Then
		Dim lArticle, postLog, pws, pwtips, pwtitle, pwcomm, IsShow, keyword, description
		pws = Trim(Request.Form("log_Readpw"))
		pwtips = Trim(Request.Form("log_Pwtips"))
		pwtitle = Request.Form("log_Pwtitle")
		pwcomm = Request.Form("log_Pwcomm")
		keyword = Trim(Request.Form("log_KeyWords"))
		description = Trim(Request.Form("log_Description"))
    If CheckStr(Request.Form("log_IsHidden")) = "1" Then
			IsShow = False
			If IsEmpty(pws) or IsNull(pws) or pws = "" Then
			Else
				pws = md5(pws)
			End If
			If pws = "" Then pwtips = ""
    Else
			IsShow = True
			pws = ""
			pwtips = ""
			pwtitle = False
			pwcomm = False
    End If
    If Request.Form("log_pws") = "0" Then
			pws = ""
			pwtips = ""
    End If
    If CheckStr(Request.Form("log_Meta")) = "0" Then
			keyword = ""
			description = ""
    End If
   
	Set lArticle = New logArticle
    lArticle.categoryID = request.Form("log_CateID")
    lArticle.logTitle = request.Form("title")
    lArticle.logAuthor = memName
    lArticle.logEditType = request.Form("log_editType")
    lArticle.logIntroCustom = request.Form("log_IntroC")
    lArticle.logIntro = request.Form("log_Intro")
    lArticle.logWeather = request.Form("log_weather")
    lArticle.logLevel = request.Form("log_Level")
    lArticle.logCommentOrder = request.Form("log_comorder")
    lArticle.logDisableComment = request.Form("log_DisComment")
    lArticle.logIsShow = IsShow
    lArticle.logIsTop = request.Form("log_IsTop")
    lArticle.logIsDraft = request.Form("log_IsDraft")
    lArticle.logFrom = request.Form("log_From")
    lArticle.logFromURL = request.Form("log_FromURL")
    lArticle.logDisableImage = request.Form("log_disImg")
    lArticle.logDisableSmile = request.Form("log_DisSM")
    lArticle.logDisableURL = request.Form("log_DisURL")
    lArticle.logDisableKeyWord = request.Form("log_DisKey")
    lArticle.logMessage = request.Form("Message")
    lArticle.logTrackback = request.Form("log_Quote")
    lArticle.logTags = request.Form("tags")
    lArticle.logPubTime = request.Form("PubTime")
    lArticle.logPublishTimeType = request.Form("PubTimeType")
    If blog_postFile = 2 Then
    lArticle.logCname = request.Form("cname")
    lArticle.logCtype = request.Form("ctype")
    End If
    lArticle.logReadpw = pws
    lArticle.logPwtips = pwtips
    lArticle.logPwtitle = pwtitle
    lArticle.logPwcomm = pwcomm
    lArticle.logMeta = request.Form("log_Meta")
    lArticle.logKeyWords = keyword
    lArticle.logDescription = description
    if request.form("FirstPost") = 1 then
		lArticle.isajax = false
		lArticle.logIsDraft = false
		postLog = lArticle.editLog(request.Form("postbackId"))
	else
		lArticle.isajax = false
    	postLog = lArticle.postLog
	end if
    Set lArticle = Nothing


%>
		      <div id="MsgContent" style="width:300px">
		        <div id="MsgHead">反馈信息</div>
		        <div id="MsgBody">
		  		 <div class="<%if postLog(0)<0 Then response.write "ErrorIcon" else response.write "MessageIcon"%>"></div>
		          <div class="MessageText"><%=postLog(1)%><br/><a href="default.asp">点击返回首页</a><br/>
		  		 <%if postLog(0)>=0 Then %>
			  		 <a href="default.asp?id=<%=postLog(2)%>">返回你所发表的日志</a><br/>
			  		 <meta http-equiv="refresh" content="3;url=default.asp?logID=<%=postLog(2)%>"/>
			     <%end if%>
		  	  </div>
		  	</div>
		    </div>
		    <%
Else
    If Request.Form("log_CateID") = Empty Then
%>
   <!--第一步-->
   <script language="javascript">
    function chkFrm(){
     if (document.forms["frm"].log_CateID.value=="") {
      alert("请选择日志分类")
  	return false
     }
     return true
    }
   </script>
    <form name="frm" action="blogpost.asp" method="post" onsubmit="return chkFrm()">
      <div id="MsgContent" style="width:350px">
        <div id="MsgHead">发表日志 - 选择分类</div>
        <div id="MsgBody">
          <table width="100%" border="0" cellpadding="3" cellspacing="0">
          <tr><td colspan="2" align="left" style=" padding:2px 2px 2px 2px">
          <ol>
          	<li>您必须选择分类后才可以进行下一步操作.</li>
            <li>如果您需要立即增加新分类请点击"增加新分类"链接.</li>
            <li>请选择编辑器类型,默认为UBB编辑器.</li>
          </ol>
          </td></tr>
    <tr>
      <td width="100" align="right"><span style="font-weight: bold">选择日志分类:</span></td>
      <td align="left"><span style="font-weight: bold">
        <select name="log_CateID" id="select2">
          <option value="" selected="selected" style="color:#333">请选择分类</option>
          <%
outCate

Sub outCate
    Dim Arr_Category, Category_Len, i
    Arr_Category = Application(CookieName&"_blog_Category")
    If UBound(Arr_Category, 1) = 0 Then Exit Sub
    Category_Len = UBound(Arr_Category, 2)

    For i = 0 To Category_Len
        If Not Arr_Category(4, i) Then
            If CBool(Arr_Category(10, i)) Then
                If stat_ShowHiddenCate And stat_Admin Then Response.Write("<option value='"&Arr_Category(0, i)&"'>&nbsp;&nbsp;&nbsp;"&Arr_Category(1, i)&"&nbsp;["&Arr_Category(7, i)&"]&nbsp;&nbsp;</option>")
            Else
                Response.Write("<option value='"&Arr_Category(0, i)&"'>&nbsp;&nbsp;&nbsp;"&Arr_Category(1, i)&"&nbsp;["&Arr_Category(7, i)&"]&nbsp;&nbsp;</option>")
            End If
        End If
    Next
End Sub

%>
        </select>&nbsp;<a href="javascript:void(0)" onclick="showPopup('增加新分类', AddNewCate(), 400);">增加新分类</a>
      </span></td>
    </tr>
    <tr>
      <td align="right"><span style="font-weight: bold">选择编辑类型:</span></td>
      <td align="left"><label title="UBB编辑器" for="ET1" accesskey="U"><input type="radio" id="ET1" name="log_editType" value="1" checked="checked" />UBBeditor</label>         <label title="FCK在线编辑器" for="ET2" accesskey="K">
          <input name="log_editType" type="radio" id="ET2" value="0" />         
          FCKeditor</label></td>
    </tr>
    <tr>
    <td colspan="2" align="center"><input name="submit" type="submit" class="userbutton" value="下一步" accesskey="N"/> <input name="button" type="button" class="userbutton" value="返回主页" onclick="location='default.asp'" accesskey="Q"/></td>
    </tr>
  </table>
  
  	  </div>
  	</div>
  </form>
  <%Else
    Dim log_editType, editTs
    log_editType = Request.Form("log_editType")

%>
  <!--第二步-->
    <form name="frm" action="blogpost.asp" method="post" onsubmit="return CheckPost()">
      		    <input name="log_CateID" type="hidden" id="log_CateID" value="<%=Request.Form("log_CateID")%>"/>
                <input name="log_editType" type="hidden" id="log_editType" value="<%=log_editType%>"/>
  				<input name="action" type="hidden" value="post"/>
                <input name="FirstPost" type="hidden" value="0"/>   
                <input name="postbackId" type="hidden" value="0"/>
                <input name="log_IsDraft" type="hidden" id="log_IsDraft" value="False"/>
  	<div id="MsgContent" style="width:700px">
        <div id="MsgHead">在 【<%=Conn.ExeCute("SELECT cate_Name FROM blog_Category WHERE cate_ID="&Request.Form("log_CateID")&"")(0)%>】 发表日志</div>
        <div id="MsgBody">
        <script language="javascript" type="text/javascript" src="common/pinyin.js"></script>
          <table width="100%" border="0" cellpadding="2" cellspacing="0">
            <tr>
              <td width="76" height="24" align="right" valign="top"><span style="font-weight: bold">标题:</span></td>
              <td align="left"><input name="title" type="text" class="inputBox" id="title" size="50" maxlength="50"/>
              </td>
            </tr>
			<%If blog_postFile = 2 Then%>
			<tr>
              <td height="24" align="right" valign="top"><span style="font-weight: bold">别名:</span></td>
              <td align="left">
			  <input name="cname" type="text" class="inputBox" id="titles" size="30" maxlength="50" onblur="check('Action.asp?action=checkAlias&Cname='+document.forms['frm'].cname.value,'CheckAlias','CheckAlias')" style="ime-mode:disabled"/>
			   <span> . </span>
			  <select name="ctype">
			    <option value="0">htm</option> 
				<option value="1">html</option>
			  </select> <span id="CheckAlias"></span>&nbsp;&nbsp;<span><a href="javascript:void(0)" onclick="$('titles').value= pinyin.go($('title').value)">自动转成开头大写拼音</a> &nbsp;&nbsp;<a href="javascript:void(0)" onclick="$('titles').value= pinyin.go($('title').value,1)">自动转成小写拼音</a></span>
              </td>
            </tr>
			<%end if%>
            <tr>
              <td align="right" valign="top"><span style="font-weight: bold">日志设置:</span></td>
              <td align="left">
                <select name="log_weather" id="logweather">
                  <option value="sunny" selected="selected">晴天 </option>
                  <option value="cloudy">多云 </option>
                  <option value="flurries">疾风 </option>
                  <option value="ice">冰雹 </option>
                  <option value="ptcl">阴天 </option>
                  <option value="rain">下雨 </option>
                  <option value="showers">阵雨 </option>
                  <option value="snow">下雪 </option>
                </select>
                <select name="log_Level" id="logLevel">
                  <option value="level1">★</option>
                  <option value="level2">★★</option>
                  <option value="level3" selected="selected">★★★</option>
                  <option value="level4">★★★★</option>
                  <option value="level5">★★★★★</option>
                </select>
                <label for="label">
                <input id="label" name="log_comorder" type="checkbox" value="1" checked="checked" />
        评论倒序</label>
                <label for="label2">
                <input name="log_DisComment" type="checkbox" id="label2" value="1" />
        禁止评论</label>
                <label for="label3">
                <input name="log_IsTop" type="checkbox" id="label3" value="1" />
        日志置顶</label>
              </td>
            </tr>
			<tr>
               <td align="right" valign="top"><span style="font-weight: bold">隐私及Meta:</span></td>
               <td align="left"><div>
	 				<label for="Secret">
	                <input id="Secret" name="log_IsHidden" type="checkbox" value="1" onClick="document.getElementById('Div_Password').style.display=(this.checked)?'block':'none'" />
	        设置日志隐私</label>
	 				<label for="Meta">
	                <input id="Meta" name="log_Meta" type="checkbox" value="1" onclick="document.getElementById('Div_Meta').style.display=(this.checked)?'block':'none'" />
	        自定义日志页Meta信息</label></div>
	                  <div id="Div_Password" style="display:none;" class="tips_body">
                          <label for="bpws1"><input id="bpws1" type="radio" name="log_pws" value="0" checked/><b>私密日志</b></label> - 私密日志只有主人和作者能查阅<br/>
                          <label for="bpws2"><input id="bpws2" type="radio" name="log_pws" value="1"/><b>加密日志</b></label> - 加密日志允许客人输入正确的密码即可查看
                          <br/>&nbsp;&nbsp;&nbsp;&nbsp;
                          <span style="font-weight: bold">密码:</span>
                          <input onFocus="this.select();$('bpws2').checked='checked'" name="log_Readpw" type="password" id="log_Readpw" size="12" class="inputBox" title="不需要加密则留空" />
                          <span style="font-weight: bold">密码提示:</span>
                          <input onFocus="$('bpws2').checked='checked'" name="log_Pwtips" type="text" id="log_Pwtips" size="35" class="inputBox" title="不需要提示则留空" />
                          <label for="bpws3"><input id="bpws3" name="log_Pwtitle" type="checkbox" value="1" checked="checked" />加密标题</label>
                          <label for="bpws4"><input id="bpws4" name="log_Pwcomm" type="checkbox" value="1" />加密评论</label>
	                  </div>
	                  <div id="Div_Meta" style="display:none;" class="tips_body">
      	 				  - 自定义日志页面头的Meta信息，留空则默认为Tag和日志摘要<br/>
		                  <span style="font-weight: bold">KeyWords&nbsp;&nbsp;:</span>
						  <input name="log_KeyWords" type="text" class="inputBox" id="log_KeyWords" title="填写你的keywords，利于搜索引擎，不需要则留空" size="80" maxlength="254" />
						  <br />
						  <span style="font-weight: bold">Description:</span>
						  <input name="log_Description" type="text" class="inputBox" id="log_Description" title="填写你的Description，利于搜索引擎，不需要则留空" size="80" maxlength="254" />
	                  </div>
				  </td>
             </tr>
            <tr>
              <td height="24" align="right" valign="top"><b>来源:</b></td>
              <td align="left"><span style="font-weight: bold"></span>
                  <input name="log_From" type="text" id="log_From" value="本站原创" size="12" class="inputBox" />
                  <span style="font-weight: bold">网址:</span>
                  <input name="log_FromURL" type="text" id="log_FromURL" value="<%=siteURL%>" size="38" class="inputBox" />
                </td>
            </tr>
            <tr>
              <td height="24" align="right" valign="top"><span style="font-weight: bold">发表时间:</span></td>
              <td align="left">
                  <label for="P1"><input name="PubTimeType" type="radio" id="P1" value="now" size="12" checked/>当前时间</label> 
                  <label for="P2"><input name="PubTimeType" type="radio" id="P2" value="com" size="12" />自定义日期:</label>
                  <input onfocus="this.select();$('P2').checked='checked'" name="PubTime" type="text" value="<%=DateToStr(now(),"Y-m-d H:I:S")%>" size="21" class="inputBox" /> (格式:yyyy-mm-dd hh:mm:ss)
                </td>
            </tr>
            <tr>
              <td height="24" align="right" valign="top"><span style="font-weight: bold">Tags:</span></td>
              <td align="left">
                      <input name="tags" type="text" value="" size="50" class="inputBox" /> <img src="images/insert.gif" alt="插入已经使用的Tag" onclick="popnew('getTags.asp','tag','250','324')" style="cursor:pointer"/> (tag之间用英文的空格或逗号分割)
               </td>
            </tr>
             <tr>
              <td  align="right" valign="top"><span style="font-weight: bold">内容:</span></td>
              <td align="center"><%
If log_editType = 0 Then
    Dim sBasePath
    sBasePath = "FCKeditor/"
    Dim oFCKeditor
    Set oFCKeditor = New FCKeditor
    oFCKeditor.BasePath = sBasePath
    oFCKeditor.Config("AutoDetectLanguage") = False
    oFCKeditor.Config("DefaultLanguage") = "zh-cn"
    oFCKeditor.Value = ""
    oFCKeditor.Height = "350"
    oFCKeditor.Create "Message"
Else
    UBB_TextArea_Height = "200px;"
    UBB_AutoHidden = False
    UBBeditor("Message")
End If

%></td>
            </tr>
            <tr>
              <td align="right" valign="top">&nbsp;</td>
               <td align="left">
  <%if log_editType<>0 then %>
               <label for="label4">
                <label for="label4"><input id="label4" name="log_disImg" type="checkbox" value="1" />
  禁止显示图片</label>
                <label for="label5">
                <input name="log_DisSM" type="checkbox" id="label5" value="1" />
  禁止表情转换</label>
                <label for="label6">
                <input name="log_DisURL" type="checkbox" id="label6" value="1" />
  禁止自动转换链接</label>
                <label for="label7">
                <input name="log_DisKey" type="checkbox" id="label7" value="1" />
  禁止自动转换关键字</label>
  <%else%>
                <strong>[&nbsp;&nbsp;<a herf="#" onClick="GetLength();" style="cursor:pointer">统计字数</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a herf="#" onClick="SetContents();" style="cursor:pointer">清空内容</a>&nbsp;&nbsp;]</strong>
  <%end if%></td></tr>
          <tr>
              <td align="right" valign="top"><span style="font-weight: bold">内容摘要:</span></td>
              <td align="left"><div><label for="shC"><input id="shC" name="log_IntroC" type="checkbox" value="1" onclick="document.getElementById('Div_Intro').style.display=(this.checked)?'block':'none'"/>编辑内容摘要</label></div>
              <div id="Div_Intro" style="display:none">
              <%
If log_editType = 0 Then
    Dim oFCKeditor1
    Set oFCKeditor1 = New FCKeditor
    oFCKeditor1.BasePath = sBasePath
    oFCKeditor1.Height = "150"
    oFCKeditor1.ToolbarSet = "Basic"
    oFCKeditor1.Config("AutoDetectLanguage") = False
    oFCKeditor1.Config("DefaultLanguage") = "zh-cn"
    oFCKeditor1.Value = ""
    oFCKeditor1.Create "log_Intro"
Else

%>
  	         <textarea name="log_Intro" class="editTextarea" style="width:99%;height:120px;"></textarea>
  	         <%
End If

%></div>
              </td>
          </tr>          <tr>
              <td align="right" valign="top" nowrap><span style="font-weight: bold">附件上传:</span></td>
              <td align="left"><iframe src="attachment.asp" width="100%" height="24" frameborder="0" scrolling="no" border="0" frameborder="0"></iframe></td>
            </tr>
            <tr>
              <td align="right" valign="top"><span style="font-weight: bold">引用通告:</span></td>
              <td align="left"><input name="log_Quote" type="text" size="80" class="inputBox" id="logQuote"/><br>请输入网络日志项的引用通告URL。可以用逗号分隔多个引用通告地址.          </td>
            </tr>
            <tr>
              <td colspan="2" align="center">
                <input name="SaveArticle" type="submit" class="userbutton" value="提交日志" accesskey="S"/>
                <input name="SaveDraft" type="submit" class="userbutton" value="保存为草稿" accesskey="D" onclick="document.getElementById('log_IsDraft').value='True'"/>
                <input name="ReturnButton" type="button" class="userbutton" value="返回" accesskey="Q" onClick="history.go(-1)"/></td>
            </tr>
            <tr>
              <td colspan="2" align="right">
                友情提示:保存草稿后，日志不会在日志列表中出现。只有再次编辑，<b>取消草稿</b>后才显示出来。</td>
            </tr>
           
           </table>
        </div>
  	</div>
  </form>
  <%
End If
End If
End If
Else
%>
   <div style="text-align:center;">
    <div id="MsgContent" style="width:300px">
      <div id="MsgHead">日志发表错误</div>
      <div id="MsgBody">
		 <div class="ErrorIcon"></div>
        <div class="MessageText">不允许外部链接提交数据<br/><a href="default.asp">点击返回首页</a>
		 <meta http-equiv="refresh" content="3;url=default.asp"/></div>
	  </div>
	</div>
  </div> 
  <%end if%><br/>
 </div> 
</div>
<!--#include file="plugins.asp" -->
<!--#include file="footer.asp" -->
