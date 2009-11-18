﻿// JavaScript Document
var AsFiled = new Array();
function Check(){
	init();
	function init(){
		
	}
	// 用户
	this.User = {
		GetCode : function(Str, id){
			$(id).innerHTML = "<img id=\"vcodeImg\" src=\"about:blank\" onerror=\"this.onerror=null;this.src='" + Str + "?s='+Math.random();\" alt=\"" + lang.Set.Asp(4) + "\" title=\"" + lang.Set.Asp(5) + "\" style=\"margin-right:40px;cursor:pointer;width:40px;height:18px;margin-bottom:-4px;margin-top:3px;\" onclick=\"src='" + Str + "?s='+Math.random()\"/>";
		},
		CheckCode : function(FormObj, ToObj){
			var CheckValue = $(FormObj).value.trim();
			if (CheckValue.length >= 4){
				Ajax({
				  url : "../pjblog.logic/log_Ajax.asp?action=CheckCode&s=" + Math.random(),
				  method : "GET",
				  content : "",
				  oncomplete : function(obj){
						var bvalue = obj.responseText.trim();
						if (bvalue == CheckValue){
							$(ToObj).innerHTML = "<img src=\"../images/check_right.gif\" />";
						}else{
							$(ToObj).innerHTML = "<img src=\"../images/check_error.gif\" />";
						}
				  },
				  ononexception:function(obj){
					  alert(obj.state);
				  }
			   	});
			}
		}
	}
	// 分类
	this.Category = {
		Add : function(obj){
			_obj = obj;
			obj.innerHTML = "正在提交...";
			obj.disabled = true;
			var new_order = $("new_order").value;
			var new_icon = $("new_icon").options[$("new_icon").options.selectedIndex].value;
			var new_name = $("new_name").value;
			var new_Intro = $("new_Intro").value;
			var new_Part = $("new_Part").value;
			var new_URL = $("new_URL").value;
			var new_local = $("new_local").options[$("new_local").options.selectedIndex].value;
			var new_Secret = $("new_Secret").options[$("new_Secret").options.selectedIndex].value;
			
			
			if ((new_order.legnth < 1) || (!/^\d+$/.test(new_order))){alert("您所填写的排序格式不正确!");$("new_order").select();obj.innerHTML = "保存新分类" ; obj.disabled = false; return;}
			if (new_icon.length < 1){alert("您所选择的图标不正确!"); obj.innerHTML = "保存新分类" ; obj.disabled = false; return;}
			if (new_name.length < 2){alert("标题格式不正确或为空, 标题应大于2位字符!"); $("new_name").select(); obj.innerHTML = "保存新分类" ; obj.disabled = false; return;}
			
			
			Ajax({
				url : "../pjblog.logic/control/log_category.asp?action=add&s=" + Math.random(),
				method : "POST",
				content : "cate_Order=" + escape(new_order) + "&cate_icon=" + escape(new_icon) + "&cate_Name=" + escape(new_name) + "&cate_Intro=" + escape(new_Intro) + "&cate_Folder=" + escape(new_Part) + "&cate_URL=" + escape(new_URL) + "&cate_local=" + escape(new_local) + "&cate_Secret=" + escape(new_Secret),
				oncomplete : function(obj){
					var json = obj.responseText.json();
					if (json.Suc){
						Box.selfWidth = true;
						Box.selefHeight = true;
						var layer = Box.FollowBox($("AddRowMark_del"), $("AddRowMark_del").offsetWidth, $("AddRowMark_del").offsetHeight, 0, "保存新分类成功!");
						layer.className = "opacity";
						layer.style.cssText += "; margin:0 auto; text-align:center; line-height:30px; font-size:11px; color:#000000; font-weight:bolder";
						layer.id = "layerTip";
						setTimeout("$('layerTip').parentNode.removeChild($('layerTip'))", 2000);
						
						$("AddRowMark_del").style.backgroundColor = "#ffffff";
						_obj.disabled = false;
						
						if (new_URL.length > 0){
							$("new_Secret").disabled = true;
							var _hidden = document.createElement("div");
							_hidden.innerHTML = "<input type=\"hidden\" value=\"0\" name=\"cate_Secret\">";
							$("new_Secret").parentNode.appendChild(_hidden);
						}
						
						// --------------------------------------------------
						var checkbox = document.createElement("div");
						checkbox.innerHTML = "<input type=\"checkbox\" value=\"" + json.Info.trim() + "\" name=\"SelectID\" /><input type=\"hidden\" value=\"" + json.Info.trim() + "\" name=\"Cate_ID\" />";
						$("new_selectid").parentNode.replaceChild(checkbox, $("new_selectid"));
						// --------------------------------------------------
						var _div = document.createElement("div");
						_div.innerHTML = "<input type=\"text\" class=\"text\" name=\"cate_count\" value=\"0\" size=\"2\" readonly=\"readonly\" style=\"background:#ffe\"/> 篇";
						_obj.parentNode.replaceChild(_div, _obj);
						
						$("AddRowMark_del").id = "";
						$("new_order").id = "";
						$("new_icon").id = "";
						$("new_name").id = "";
						$("new_Intro").id = "";
						$("new_Part").id = "";
						$("new_URL").id = "";
						$("new_local").id = "";
						$("new_Secret").id = "";
						try{$("Addbutton").disabled = false}catch(e){}
					}else{alert(json.Info);_obj.disabled = false; _obj.innerHTML = "保存新分类" ;}
				},
				ononexception:function(obj){
					alert(obj.state);
				}
			});
		}
	},
	this.Clear = function(obj){
		var _obj = obj;
		$("clearTr").style.display = "block";
		_obj.disabled = true;
		Ajax({
		  url : "../pjblog.logic/control/log_category.asp?action=clear&s=" + Math.random(),
		  method : "GET",
		  content : "",
		  oncomplete : function(obj){
				var value = obj.responseText;
				$("clear").innerHTML = value;
				_obj.disabled = false;
		  },
		  ononexception:function(obj){
			  alert(obj.state);
		  }
		});
	},
	this.comment = {
		post : function(){
			var ajax = new Ajax();
    			ajax.postf(
        			$("postform"),
        			function(obj) {
						var json = obj.responseText.json();
						if (json.Suc){
							var str = cee.decode(json.Info);//最好返回的值
							var div = document.createElement("div");
							div.id = "comment_" + json.id;
							div.innerHTML = str;
							$("commentBox").insertBefore(div, $("commentBox").childNodes[0]);
							location = "#comment_" + json.id;
							Source = "#ffffff";
							Target = "#C2D6D6";
							flash("commenttop_" + json.id);
						}
					}
    			);
		},
		page : function(id, needTip, url){
			if (needTip){$("commentBox").innerHTML = "正在加载评论, 请稍后..."}
			var cJS = document.createElement("script");
			cJS.chatset = "utf-8";
			cJS.src = url + "&page=" + id + "&s=" + Math.random();
			document.getElementsByTagName("HEAD")[0].appendChild(cJS);
		}
	},
	this.Static = {
		AddRow : function(obj, Mark, offset){
			try{$("StaticPre").parentNode.removeChild($("StaticPre"));}catch(e){}
			var Static = new TableAddRow(obj);
			Static.Mark = Mark;
			var Row = Static.AddRow(offset);
			Row.id = "StaticPre";
			var td = Row.insertCell(0);
			var div = document.createElement("div")
			td.appendChild(div);
			div.innerHTML = "&nbsp;";
			td = Row.insertCell(1);
			td.setAttribute("colspan", 4); // 并列4行
			div = document.createElement("div");
			var t = div;
			td.appendChild(div);
			td = Row.insertCell(2);
			div = document.createElement("div");
			td.appendChild(div);
			div.innerHTML = "&nbsp;";
			return t;
		},
		CheckboxDisabled : function(T){ // 设置所有checkbox属性
			var s = document.getElementsByTagName("input");
			for (var i = 0 ; i < s.length ; i++){
				if (s[i].type == "checkbox") s[i].disabled = T;
			}
		},
		CheckboxChecked : function(_this){
			var s = document.getElementsByTagName("input");
			for (var i = 0 ; i < s.length ; i++){
				if (s[i].checked) s[i].checked = false;
			}
			_this.checked = true;
		},
		index : function(obj, Mark, offset, _this){
			this.CheckboxChecked(_this);
			var element = this.AddRow(obj, Mark, offset);
			element.style.cssText += "; border: 1px solid #7FCAE2; padding:10px 10px 10px 10px; max-height:200px; overflow:auto";
			var c = "<div class=\"static\">";
			c += "<div class=\"staticHead\"><span class=\"left\">首页静态化过程内容较多, 请耐心等待...</span><span class=\"right\" id=\"index_File\">Saving...</span></div>";
			c += "<div class=\"staticBody\"><div id=\"index_box\">点击按钮开始生成...</div><input type=\"button\" value=\"开始生成\" class=\"button\" onclick=\"CheckForm.Static.AjaxIndex(this)\"></div>";
			c += "</div>"
			element.innerHTML = c;
		},
		Article : function(obj, Mark, offset, _this){
			this.CheckboxChecked(_this);
			var element = this.AddRow(obj, Mark, offset);
			element.style.cssText += "; border: 1px solid #7FCAE2; padding:10px 10px 10px 10px;";
			var c = "<div class=\"static\">";
			c += "<div class=\"staticHead\"><span class=\"left\">内容页静态化过程内容较多, 请耐心等待...</span><span class=\"right\">Total : <span id=\"Article_Total\">0</span> piece Local : <span id=\"Article_Local\">0</span> </span></div>";
			c += "<div class=\"staticBody\"><ol id=\"Article_box\">";
			c += "<li><span class=\"left\">我们那年孩提时的欢乐与快乐</span><span class=\"right\">html/xxx/xxxxxx.html</span></li>";
			c += "<li><span class=\"left\">我们是一群啊师傅很骄傲是阿使客户科技的罚款.</span><span class=\"right\">html/xxx/xxxxxx.html</span></li>";
			c += "<li><span class=\"left\">的萨菲哈市飞机的故事飞机干啥借古讽今尸鬼封尽的萨嘎飞机国际</span><span class=\"right\">html/xxx/xxxxxx.html</span></li>";
			c += "<li><span class=\"left\">阿瑟的饭局上好按时开放后开始的发行可还是阿海珐开始的恢复说得好</span><span class=\"right\">html/xxx/xxxxxx.html</span></li>";
			c += "<li><span class=\"left\">的说法很快分哈市开发和卡萨幅度十分看好爱的身份还是开发和卡斯</span><span class=\"right\">html/xxx/xxxxxx.html</span></li>";
			c += "</ol>";
			c += "<div><input type=\"button\" value=\"开始生成\" class=\"button\" onclick=\"CheckForm.Static.AjaxGetArticleID(this)\"></div></div>";
			c += "</div>";
			element.innerHTML = c;
		},
		Category : function(obj, Mark, offset, _this){
			this.CheckboxChecked(_this);
			var element = this.AddRow(obj, Mark, offset);
			element.style.cssText += "; border: 1px solid #7FCAE2; padding:10px 10px 10px 10px;";
			var c = "<div class=\"static\">";
			c += "<div class=\"staticHead\"><span class=\"left\">内容页静态化过程内容较多, 请耐心等待...</span><span class=\"right\">Total : <span id=\"Category_Total\">0</span> piece Local : <span id=\"Category_Local\">0</span> </span></div>";
			c += "<div class=\"staticBody\">" // AjaxGetCategoryID
			c += "<ol id=\"categoryBox\">"
			c += "<li>点击开始静态化</li>"
			c += "</ol>"
			c += "<div><input type=\"button\" value=\"开始生成\" class=\"button\" onclick=\"CheckForm.Static.AjaxGetCategoryID(this)\"></div></div>";
			"</div>";
			c += "</div>"
			element.innerHTML = c;
		},
		AjaxIndex : function(o){
			o.disabled = true;
			$("index_box").innerHTML = "正在生成首页静态文件...<br />";
			Ajax({
			  url : "../pjblog.logic/log_webconfig.asp?action=default&s=" + Math.random(),
			  method : "GET",
			  content : "",
			  oncomplete : function(obj){
					var json = obj.responseText.json();
					if (json.Suc){$("index_File").innerHTML = "Saved : " + json.Info.trim();}else{$("index_File").innerHTML = "Saved Error!"}
					if (json.Suc) {$("index_box").innerHTML = $("index_box").innerHTML + "生成首页静态文件成功!<br />";}else{$("index_box").innerHTML = $("index_box").innerHTML + json.Info;}
					o.disabled = false;
			  },
			  ononexception:function(obj){
				  alert(obj.state);
			  }
			});
		},
		AjaxGetArticleID : function(o){
			_this = this;
			$("Article_Total").innerHTML = "0";
			$("Article_Local").innerHTML = "0";
			o.disabled = true;
			var _o = o;
			$("Article_box").innerHTML = "";
			this.CreateLi("Article_box", "正在获取日志ID总数和ID结构...")
			Ajax({
			  url : "../pjblog.logic/log_webconfig.asp?action=getarticleid&s=" + Math.random(),
			  method : "GET",
			  content : "",
			  oncomplete : function(obj){
					var json = obj.responseText.json();
					if (json.Suc){
						var total = json.total;
						var id = json.id;
						$("Article_Total").innerHTML = total;
						_this.CreateLi("Article_box", "获取日志ID总数和ID结构成功, 开始静态化!");
						var sSplit = id.split(",");
						AsFiled = new Array();
						for (var c = 0 ; c < sSplit.length ; c++){
							AsFiled.push(sSplit[c]);
						}
						if (total > 0){
							_this.AjaxArticle(AsFiled[0], 1, total, _o);
						}else{_this.CreateLi("Article_box", "没有数据需要静态化!");o.disabled = false;}
					}else{
						_this.CreateLi("Article_box", "获取日志ID总数和ID结构失败!");
						_o.disabled = false;
					}
			  },
			  ononexception:function(obj){
				  alert(obj.state);
			  }
			});
		},
		CreateLi : function(obj, html){
			var li = document.createElement("li");
			$(obj).appendChild(li);
			li.innerHTML = html;
			$(obj).scrollTop = parseInt($(obj).scrollHeight);
		},
		AjaxArticle : function(id, i, j, o){
			var _this = this, _o = o;
			var _i = i, _j = j;
			Ajax({
			  url : "../pjblog.logic/log_webconfig.asp?action=article&id=" + id + "&s=" + Math.random(),
			  method : "GET",
			  content : "",
			  oncomplete : function(obj){
					var json = obj.responseText.json();
					var Path = json.Path;
					var Title = json.Title;
					var str = function(doAs){return "<span class=\"left\">" + id + "." + Title + " (" + doAs + ")</span><span class=\"right\">" + Path + "</span>"}
					$("Article_Local").innerHTML = _i;
					if (json.Suc){
						_this.CreateLi("Article_box", str("<font color=green>成功</font>"));
					}else{
						_this.CreateLi("Article_box", str("<font color=red>失败</font>"));
					}
					_i++;
					if (parseInt(_i) > parseInt(_j)){
						_this.CreateLi("Article_box", "静态化内容页完毕!");
						_o.disabled = false;
						AsFiled = new Array();
					}else{
						_this.AjaxArticle(AsFiled[_i - 1], _i, _j, _o);
					}
			  },
			  ononexception:function(obj){
				  alert(obj.state);
			  }
			});
		},
		AjaxGetCategoryID : function(o){
			$("Category_Total").innerHTML = "";
			$("Category_Local").innerHTML = "";
			_this = this;
			var _o = o;
			_o.disabled = true;
			_this.CreateLi("categoryBox", "正在获取分类总数和分类结构...");
			Ajax({
			  url : "../pjblog.logic/log_webconfig.asp?action=getcategoryid&s=" + Math.random(),
			  method : "GET",
			  content : "",
			  oncomplete : function(obj){
					var json = obj.responseText.json();
					if (json.Suc){
						_this.CreateLi("categoryBox", "开始静态化分类列表");
						var total = json.total;
						var id = json.id;
						$("Category_Total").innerHTML = total;
						AsFiled = new Array();
						var sSplit = id.split(",");
						for (var c = 0 ; c < sSplit.length ; c++){
							var d = sSplit[c].split("|");
							var h = [d[0], d[1]]
							AsFiled.push(h);
						}
						if (parseInt(total) > 0){
							_this.AjaxCategory(AsFiled[0], 1, total, _o);
						}else{_this.CreateLi("categoryBox", "没有数据需要静态化!");o.disabled = false;}
					}else{
						_this.CreateLi("categoryBox", "获取分类信息失败!");
						_o.disabled = false;
					}
			  },
			  ononexception:function(obj){
				  alert(obj.state);
			  }
			});
		},
		AjaxCategory : function(arr, i, j, o){
			var _o = o, _this = this;
			var _i = i, _j = j;
			Ajax({
			  url : "../pjblog.logic/log_webconfig.asp?action=category&id=" + escape(arr[0]) + "&folder=" + escape(arr[1]) + "&s=" + Math.random(),
			  method : "GET",
			  content : "",
			  oncomplete : function(obj){
					var json = obj.responseText.json();
					var info = json.Info;
					var folder = json.folder;
					$("Category_Local").innerHTML = _i;
					if (json.Suc){
						_this.CreateLi("categoryBox", "<span class=\"left\">创建" + folder + "文件夹分类 (<font color=green>成功</font>)</span><span class=\"right\">" + info + "</span>");
					}else{
						_this.CreateLi("categoryBox", "创建" + folder + "文件夹分类 (<font color=red>失败</font>)");
					}
					_i++;
					if (parseInt(_i) > parseInt(_j)){
						_this.CreateLi("categoryBox", "静态化分类页完毕!");
						_o.disabled = false;
						AsFiled = new Array();
					}else{
						_this.AjaxCategory(AsFiled[_i - 1], _i, _j, _o);
					}
			  },
			  ononexception:function(obj){
				  alert(obj.state);
			  }
			});
		}
	}
}
var CheckForm = new Check();