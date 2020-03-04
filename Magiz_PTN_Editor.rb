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

def self.dv2(g,f,n,s=0)#g为群组,f为面的位置(0-5)，n为分段数，s为两侧缩进，
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
    s = (t/m).round(0)
end

def self.refresh(p,t=100,d=0) #p为样式，t为预设的建筑高度，d为绘制细节
    m = Sketchup.active_model.entities
    m.each{|e|e.erase!}
    r1,r2,r3 = rand(2),rand(2),rand(2)
    p.each {|n| (0..10).each {|i| n[i]=eval(n[i]) if n[i].is_a?(String)&&i!=6 }}
    p.each {|n|
        c = cube(m,Geom::Point3d.new(n[0],n[1],n[2]),n[3],n[4],n[5])
        c.material = n[6]
        if d!=0||n[7]==0
            dv1(c,n[8],n[9],n[10]) if n[7]==1
            dv2(c,n[8],n[9],n[10]) if n[7]==2
        end
    }
end

def self.save_ptn 
    d = UI.savepanel("Save File", "e:/magiz", "Myptn.mgz")
    File.new(d,'w+').syswrite(@ptn.to_json) if d
end

def self.load_ptn
    d = UI.openpanel("Open File", "e:/magiz", "Magiz PTN File|*.mgz||")
    @ptn = JSON.parse(File.read(d)) if d
    SKETCHUP_CONSOLE.clear
    p @ptn
end

@ptn = {"CLRS"=>{
            "TOP"=>7829367,
            "BDY"=>12303291,
            "BTM"=>10066329,
            "SLD"=>6710886,
        },
    "PTNS"=>{
        "TierBuilding"=>{
            "t1"=>[
                [2, 2, 0, 38, 10, 20, "BDY", 1, 0, 7, "r1"], 
                [0, 0, 0, 12, 14, 24, "TOP", 2, 0, 5, 0], 
                [20, 0, 0, 24, "10+r1*4", "24-r1*8", "TOP", 2, 0, 10, 0]
                ],
            "t2"=>[
                [3, 3, 0, 34, 20, "15+r1*5", "BTM", 1, 0, 0, 0], 
                [0, 0, 0, 12, 26, "18+r1*5", "TOP", 1, 0, 8, 0], 
                [15, 0, 8, 24, 26, "10+r1*5", "BDY", 2, 0, 15, 0], 
                [15, 0, 0, 24, 26, 6, "BDY", 2, 0, 5, 0]
                ],
            "t3"=>[
                [0, 0, 0, 60, 30, 55, "TOP", 1, 0, 9, "r1"], 
                [5, 5, 15, 60, 30, "35+r1*12", "BDY", 2, 0, "12*r1", "r1"], 
                [5, 5, 0, 60, 30, "9+r1*6", "BTM", 2, 0, 0, 0]
                ],
            },
        "Skyscraper"=>{
            "s1"=>[
                ["3*r1+2*r2", "3*r1+2*r2", 90, "40-6*r1-4*r2", "40-6*r1-4*r2", "6+r1*3", "TOP", 2, 0, 6, 0], 
                ["3*r1", "3*r1", 15, "40-6*r1", "40-6*r1", 75, "BDY", 2, 0, 9, "r2"], 
                [0, 0, 0, 40, 40, 15, "BTM", 2, 0, 6, 0]
                ],
            "s2"=>[
                [6, 6, 76, 28, 28, 3, "TOP", 1, 0, "3*r1", 0], 
                [3, 3, 73, 34, 34, 3, "TOP", 1, 0, "3*r1", 0], 
                [0, 0, 70, 40, 40, 3, "TOP", 1, 0, "3*r1", 0], 
                [0, 0, 0, 40, 40, 70, "BDY", 2, 0, 8, "r1"], 
                ],
            "s3"=>[
                [0, 3, 0, 60, 20, "70+r3*6", "TOP", 2, 0, 7, "r1"], 
                [5, 0, 13, 50, 26, 60, "BDY", 1, 0, 24, "r2"], 
                [5, 0, 0, 50, 26, "10+r1*3", "BTM", 2, 0, 6, 0]
                ],
            "s4"=>[
                [0, 3, 0, 60, 20, 80, "TOP", 1, 3, 7, "r1"], 
                [5, 0, 46, 50, 26, 30, "BDY", 1, 0, 12, "r2"], 
                [5, 0, 13, 50, 26, 30, "BDY", 1, 0, 12, "r2"], 
                [5, 0, 0, 50, 26, "10+r1*3", "BTM", 2, 0, 6, 0]
                ],
            "s5"=>[
                [10, 0, 0, 20, 40, "85+r1*10", "BDY", 1, 2, 8, "r3"], 
                [5, 5, 0, 30, 30, 90, "TOP", 1, 0, 0, 0], 
                [0, 10, 0, 40, 20, "85+r2*10", "BDY", 1, 3, 8, "r3"], 
                ],
            },
        "Apartment"=>{
            "a1"=>[
                [0, 2, 0, 30, 8, 24, "BDY", 1, 0, "lv(t,3.5)", 0],
                [9, 4, 0, 12, 10, 25, "TOP", 0, 0, 0, 0],
                [6, 0, 0, 5, 3, 23, "SLD", 0, 0, 0, 0],
                [19, 0, 0, 5, 3, 23, "SLD", 0, 0, 0, 0],
                ],
            "a2"=>[
                [0, 2, 0, 30, 8, 24, "BDY", 1, 0, "lv(t,3.5)", 0],
                [9, 0, 0, 12, 12, 26, "TOP", 1, 4, 5, "r1"],
                ],
            },
        "Villa"=>{
            "v1"=>[
                [0, 2, 0, 30, 8, 24, "BDY", 1, 0, "lv(t,3.5)", 0],
                [9, 1, 0, 12, 10, 25, "BTM", 1, 2, 5, "r1"],
                [6, 0, 0, 5, 3, 6, "SLD", 0, 0, 0, 0],
                [19, 0, 0, 5, 3, 6, "SLD", 0, 0, 0, 0],
                ],
            }
        }
    }


#save_ptn

refresh(@ptn['PTNS']['Villa']['v1'],24,1)





