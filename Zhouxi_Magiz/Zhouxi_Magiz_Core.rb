#    Support: 453154007@qq.com
#
#    Copyright (C) 2019 周曦
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.


module Zhouxi
    module Magiz_New

def self.initial
    require 'json'
    @mdl = Sketchup.active_model
    @mts = @mdl.materials
    Dir.chdir(Sketchup.find_support_file('Patterns','Plugins/Zhouxi_Magiz/'))
    c,p,@tp,@nm,@cb = 'CLRS','PTNS',['Skyscraper','TierBuilding','Apartment','Villa'],0,[[0,0,0,9,9,9,"BDY",0,0,0,0]]
    h={c=>{},p=>{@tp[0]=>{},@tp[1]=>{},@tp[2]=>{},@tp[3]=>{}}}
    Dir['*.mgz'].each {|f| x = JSON.parse(File.read(f))
        h[c].merge!x[c] if x[c]
        @tp.each{|t| h[p][t].merge!x[p][t] if x[p][t]}
    }
    h[c].each {|k,v| @mts[k] ? m=@mts[k] : m=@mts.add(k)
        m.color=Sketchup::Color.new(v)
    }
    @ptn = h[p]
end

initial

def self.cube(e,p,w,d,h)#e为环境,p为原点,w为宽,d为长,h为高
    p1 = p+[w,0,0]
    p2 = p+[0,d,0]
    p3 = p+[w,d,0]
    c = e.add_group
    f = c.entities.add_face(p,p2,p3,p1)
    f.pushpull(-h,true)
    f.reverse!
    c
end

def self.dv1(g,f,n,s=0)#参数：g为群组,f为面的位置(0-5)，n为分段数，s为两侧缩进，
    fs,ps = [],[]
    g.entities.each{|e|fs << e if e.is_a?Sketchup::Face}
    vs = fs[f].vertices
    vs.each{|v| ps << v.position}
    eg = vs[0].edges-fs[f].edges
    vt = fs[f].normal.reverse
    vt.length = eg[0].length/n
    (1...n-s).each {|i|
        ps.map!{ |p| p+=vt }
        g.entities.add_edges(ps[0],ps[1],ps[2],ps[3],ps[0]) if i>s
    }
end

def self.dv2(g,f,n,s=0)#g为群组,f为面的位置(0-5)，n为分段数，s为两侧 缩进，
    fs,ps,li = [],[],[]
    g.entities.each{|e|fs << e if e.is_a?Sketchup::Face}
    fs[f].edges.each{|e| p,vt = e.start.position,e.line[1]
        vt.length = e.length/n
        (1...n-s).each{|i| p+=vt ; ps<< p if i>s}
    }
    vt = fs[f].normal.reverse
    vt.length = (fs[f].vertices[0].edges-fs[f].edges)[0].length
    ps.each {|p| li << [p,p+vt]}
    li.each {|l| g.entities.add_edges l}
end

def self.lv(t,m)
    s = (t.bounds.depth/m*0.0254).round(0)
end

def self.create(t,a,d=0) #t为目标组件，a为数组，d为细节
    case t
    when Sketchup::Group
        e = t.entities.add_group
    when Sketchup::ComponentInstance
        e = t.definition.entities.add_group
    end
    r1,r2,r3,z = rand(2),rand(2),rand(2),[]
    a.each {|n| z<< Array.new(n)}
    z.each {|n| (0..10).each {|i| n[i]=eval(n[i]) if n[i].is_a?(String)&&i!=6 }}
    z.each {|n|
        c = cube(e.entities,Geom::Point3d.new(n[0],n[1],n[2]),n[3],n[4],n[5])
        c.material = n[6]
        if d!=0||n[7]==0
            dv1(c,n[8],n[9],n[10]) if n[7]==1
            dv2(c,n[8],n[9],n[10]) if n[7]==2
        end
    }
    e.transform! Geom::Transformation.rotation(e.bounds.center,Z_AXIS,90.degrees*rand(4))
    e.transform! Geom::Transformation.new(e.bounds.min).inverse
    s = Geom::Transformation.scaling(
        t.definition.bounds.width/e.bounds.width,
        t.definition.bounds.height/e.bounds.height,
        t.definition.bounds.depth/e.bounds.depth,)
    e.transform! s
    t.definition.entities.each{|x|x.erase! if x!=e}
    f = e.explode
    f[0].explode if a[0][7]==0
end

def self.choose(t)
    if @nm==0
        h = t.bounds.depth*0.0254
        if h>24 
            x = @ptn[@tp[0]] if t.is_a?Sketchup::Group
            x = @ptn[@tp[2]] if t.is_a?Sketchup::ComponentInstance
        elsif h<=24
            x = @ptn[@tp[1]] if t.is_a?Sketchup::Group
            x = @ptn[@tp[3]] if t.is_a?Sketchup::ComponentInstance
        end
        a=x.values[rand(x.values.size)] 
    else 
        a=@ptn[@nm[0]][@nm[1]]
    end
    a==nil ? a=@cb : a
end

def self.transform_all(d,c=0)#c=1为重置体块
    @mdl.start_operation('transform', true)
        s,changed = @mdl.selection,[]
        begin
            if s.size>0
                s.each{|t| 
                    if t.is_a?(Sketchup::ComponentInstance)|| t.is_a?(Sketchup::Group)
                        c==1 ? a=@cb : a=choose(t)
                        create(t,a,d) if !changed.include?(t.definition)
                        changed<< t.definition if t.is_a?(Sketchup::ComponentInstance)
                    end
                }
            end
        rescue 
            initial
        end
    @mdl.commit_operation
end

@mgr = UI::HtmlDialog.new({ :dialog_title => "Pattern Manager", :scrollable => false, :resizable => false, :width => 300, :height => 300, :left => 75, :top => 90, :style => UI::HtmlDialog::STYLE_DIALOG })

def self.show_mgr
    css = Sketchup.find_support_file('manager.css','Plugins/Zhouxi_Magiz/Resource')
    ui="<!DOCTYPE html> <html lang='zh'> <head> <meta charset='UTF-8'> <link rel='stylesheet' type='text/css' href='#{css}'> <script type='text/javascript'> function set() { a = event.target.className;b = event.target.innerHTML;c = document.getElementById('ttl').children;c[0].innerHTML = b;c[1].innerHTML = a;sketchup.getData(a+','+b) } </script> </head> <body> <div id='ttl'> <h1>MAGIZ</h1> <p>Copyright (c) 2019 Zhou Xi<br>Version 0.4.0</p> </div> <input type='checkbox' id='trg'> <div id='btn'> <div> </div> </div> <div id='bar'> <div>"
    @ptn.each_key{ |t| @ptn[t].each_key{|k| ui+="<div class='#{t}' onclick='set()'>#{k}</div>" }}
    ui+="</div></div></body></html>"
    @mgr.set_html(ui)
    @mgr.add_action_callback("getData"){|action_context,d| @nm = d.split(',')}
    @mgr.set_on_closed { @nm=0 }
    @mgr.show
end

def self.toolbar
    d = 'Resource/'
    i = [d+'icon1.svg',d+'icon2.svg',d+'icon3.svg',d+'icon4.svg']
    tb = UI::Toolbar.new 'Magiz'
    cm1 = UI::Command.new('Transform All') {transform_all(1)}
    cm1.small_icon = cm1.large_icon = i[0]
    cm1.status_bar_text = ('Transform all the groups and Components selected')
    cm1.tooltip = 'Transform All'
    tb.add_item cm1
    cm2 = UI::Command.new('Simple Transformation') {transform_all(0)}
    cm2.small_icon = cm2.large_icon = i[1]
    cm2.status_bar_text = ('Transform all whithout details')
    cm2.tooltip = 'Simple Transformation'
    tb.add_item cm2
    cm3 = UI::Command.new('Reset') {transform_all(0,1)}
    cm3.small_icon = cm3.large_icon = i[2]
    cm3.status_bar_text = ('Transform to a cube')
    cm3.tooltip = 'Reset'
    tb.add_item cm3
    cm4 = UI::Command.new('Reset') {@mgr.visible? ? @mgr.close : show_mgr}
    cm4.small_icon = cm4.large_icon = i[3]
    cm4.status_bar_text = ('Select a Pattern')
    cm4.tooltip = 'Pattern Manager'
    tb.add_item cm4
    tb.show
end
toolbar
    end
end
