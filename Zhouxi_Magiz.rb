# Support: 453154007@qq.com
#---------------------------------------------Copyright----------------
#    Copyright (C) 2019 周曦
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#---------------------------------------------Changelog----------------
#v0.3.0   @2020-2-24
#   重写全部代码，新的UI界面，支持自定义可拓展的mgz文件
#v0.2.0   @2019-12-12
#   重写全部代码，支持对群组内的群组，以及组件进行变换，优化并增加了造型模板，新增无细节变形的按钮
#v0.1.0   @2019-11-18
#   第一个版本!
require 'sketchup.rb'
require 'extensions.rb'

module Zhouxi
  module Magiz

ext = SketchupExtension.new('Magiz' , 'Zhouxi_Magiz/Zhouxi_Magiz_Core.rb' )
ext.description='将群组体块变成各种造型的建筑'
ext.version = '0.4.0'
ext.creator = '周曦'
ext.copyright = 'Copyright (c) 2019 周曦'
      # REGISTER THE EXTENSION WITH SKETCHUP:
Sketchup.register_extension ext,true

#----------------------Menu----------------------
my_notice = UI::HtmlDialog.new({
    :dialog_title => 'Help?',
    :scrollable => false,
    :resizable => true,
    :width => 180,
    :height => 250,
    :left => 85,
    :top => 100,
    :style => UI::HtmlDialog::STYLE_DIALOG
    })
dir = Sketchup.find_support_file('QRcode.png','Plugins/Zhouxi_Magiz/Resource')
notice = "<!DOCTYPE html> <html> <head></head> <body> <p><a href='https://gitee.com/zhou_shi_hu/Magiz' target='_blank'> <img src='#{dir}' alt='Zhou.xiii@qq.com' width=148 height=148></a></p> <p style=font-size:10px;text-align:center>Copyright 2019,Zhouxi<br>All rights reserved</p> </body> </html>"
my_notice.set_html(notice)
my_notice.show if rand(9)==0

  end
end
