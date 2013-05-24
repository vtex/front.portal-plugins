/// <reference path="../jquery-1.4.1-vsdoc.js" />
/// <reference path="../vtex.common.js" />
/// <reference path="../vtex.jsevents.js" />
/// <reference path="../vtex.skuEvents.js" />
$(document).ready(function () {
    LoadOn();
})

function LoadOn() {
    (function ($) {
        $.fn.getAttributes = function () {
            var attributes = {};

            if (!this.length)
                return this;

            $.each(this[0].attributes, function (index, attr) {
                if (attr.name != "action" && attr.name.substr(0, 3) == 'vt-') {
                    attributes['cfg_' + MakeOriginalCaseToAttrName(attr.nodeName.substr(3))] = attr.nodeValue;
                }
            });

            return attributes;
        }
    })(jQuery);

    
//    $('vt').each(function (i, element) {
//        VT__Run($(this))
//    })


    $('[id=__vt]').each(function (i, element) {
        VT__Run($(this))
    })

}

function VT__Run(tag) {
    var action = $(tag).attr('action');
    var cssclass = $(tag).attr('vt-class');
    var post = $(tag).getAttributes();
    LoadContentInTag(action, post, $(tag), cssclass, 'iframes');
}


function LoadContentInTag(action, post, tag, cssclass, type) {
	if(type == 'iframe') {
		var queryString = GetQueryString();
		queryString = BuildQueryString(post, queryString);
		var url = window.location.origin + '/ViewPart/' +  action + '/' + queryString;
		divContainer = $('<div />').html("<iframe src='" + url + "'></iframe>");
		tag.replaceWith(divContainer);
		$('#' + tag.attr('vt-uid')).remove();
		return;
	}
	else {

		$.ajax({
			url: '//meuamigopet.vtexcommerce.com.br/ViewPart/' + action + GetQueryString(),
			data: post,
			dataType: 'jsonp',
			jsonp: 'callback',
			cache: false,
			async: true,
			success: function (data) {
				var divContainer = "";
				try
				{
					if(cssclass != undefined) {
						divContainer = $('<div />').addClass(cssclass).html(data.message);
					}
					else {
						divContainer = $('<div />').html(data.message);
					}
				}
				catch(err)
				{
					txt="There was an error on this page.\n\n";
					txt+="Error description: " + err.message + "\n\n";
					//alert(txt);
					divContainer = $('<div />').html(txt);
				}
				tag.replaceWith(divContainer);
				$('#' + tag.attr('vt-uid')).remove();
				return;
			},
			error: function (XMLHttpRequest, textStatus, errorThrown) {
				$('#' + tag.attr('vt-uid')).remove();
				var divContainer = $('<div />').hide().html(XMLHttpRequest.responseText);
				//alert(XMLHttpRequest.responseText);
			}
		});
	}
}

function BuildQueryString(post, queryString) {
	if(queryString == '') {
		queryString = '?a=a';
	}
	jQuery.each(post, function(i, val) {
		queryString += "&" + i + "=" + val;
	});
	//alert(string);
	return queryString;
}

function GetQueryString() {
    var originalUrl = document.location.href;
    var pos = originalUrl.indexOf('?');
	var queryString = "";
    if (pos != -1) {
        return originalUrl.substr(pos) + '&DebugJS2=true&DebugCSS=true';
    } else {
        return '?DebugJS2=true&DebugCSS=true';
    }
}

function MakeOriginalCaseToAttrName(name) {
    var char = "";
    var pos = name.indexOf("-");
    while (pos != -1) {
        char = name.substr(pos, 2);
        if (char.length == 2) {
            name = name.replace(char, char.substr(1, 1).toUpperCase());
            pos = name.indexOf("-");
        } else {
            alert("Nome de atributo inválido dentro da tag 'VT': " + name + ". \n Os nomes tem que ser em caixa baixa e os compostos separadodos por hiffen (-)");
        }
    }
    return name;
}
