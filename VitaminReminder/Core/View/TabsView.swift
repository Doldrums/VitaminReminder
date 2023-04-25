import SwiftUI
import UIKit

extension Color {
    static let veryDarkGray = Color(red: 27 / 255, green: 27 / 255, blue: 34 / 255)
    static let darkGray = Color(red: 43 / 255, green: 45 / 255, blue: 49 / 255)
    static let lightGray = Color(red: 112 / 255, green: 114 / 255, blue: 116 / 255)
}

func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
    let xDist = a.x - b.x
    let yDist = a.y - b.y
    return CGFloat(sqrt(xDist * xDist + yDist * yDist))
}

func metaball(
    _ path: inout Path,
    _ center1: CGPoint,
    _ radius1: CGFloat,
    _ center2: CGPoint,
    _ radius2: CGFloat
) {
    let v = 0.7
    let d = distance(center1, center2)
    
    var u1: CGFloat = 0
    var u2: CGFloat = 0
    if d < radius1 + radius2 {
        u1 = acos(
            (radius1 * radius1 + d * d - radius2 * radius2) / (2 * radius1 * d)
        )
        u2 = acos(
            (radius2 * radius2 + d * d - radius1 * radius1) / (2 * radius2 * d)
        )
    } else {
        u1 = 0
        u2 = 0
    }
    
    let maxSpread = acos((radius1 - radius2) / d)
    
    let a1: CGFloat = u1 + (maxSpread - u1) * v
    let a2: CGFloat = -u1 - (maxSpread - u1) * v
    let a3: CGFloat = .pi - u2 - (.pi - u2 - maxSpread) * v
    let a4: CGFloat = -.pi + u2 + (.pi - u2 - maxSpread) * v
    
    
    let p1 = CGPoint(
        x: center1.x + cos(a1) * radius1,
        y: center1.y + sin(a1) * radius1
    )
    let p2 = CGPoint(
        x: center1.x + cos(a2) * radius1,
        y: center1.y + sin(a2) * radius1
    )
    
    let p3 = CGPoint(
        x: center2.x + cos(a3) * radius2,
        y: center2.y + sin(a3) * radius2
    )
    let p4 = CGPoint(
        x: center2.x + cos(a4) * radius2,
        y: center2.y + sin(a4) * radius2
    )
    
    let d2Base = min(1.2, distance(p1, p3) / (radius1 + radius2))
    let d2 = d2Base * min(1, (d * 2) / (radius1 + radius2))
    
    let r1 = radius1 * d2;
    let r2 = radius2 * d2;
    
    let h1 = CGPoint(
        x: p1.x + cos(a1 - .pi / 2) * r1,
        y: p1.y + sin(a1 - .pi / 2) * r1
    )
    let h2 = CGPoint(
        x: p2.x + cos(a2 + .pi / 2) * r1,
        y: p2.y + sin(a2 + .pi / 2) * r1
    )
    let h3 = CGPoint(
        x: p3.x + cos(a3 + .pi / 2) * r2,
        y: p3.y + sin(a3 + .pi / 2) * r2
    )
    let h4 = CGPoint(
        x: p4.x + cos(a4 - .pi / 2) * r2,
        y: p4.y + sin(a4 - .pi / 2) * r2
    )
    
    path.move(to: p4)
    path.addCurve(to: p2, control1: h4, control2: h2)
    path.addLine(to: p1)
    path.addCurve(to: p3, control1: h1, control2: h3)
}

struct WaveTabBarShape: Shape {
    var tabCount: Int
    var circleRadius: CGFloat = 40
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let spacing = (rect.width - circleRadius * CGFloat(tabCount) * 2) / CGFloat(tabCount - 1)
        
        for i in 0..<tabCount {
            let center = CGPoint(
                x: circleRadius + CGFloat(i) * (circleRadius * 2 + spacing),
                y: rect.height / 2.0
            )
            
            path.move(to: center)
            path.addArc(
                center: center,
                radius: circleRadius,
                startAngle: Angle.zero,
                endAngle: Angle(degrees: 360),
                clockwise: true
            )
            
            if (i != 0) {
                let prevCenter = CGPoint(
                    x: circleRadius + CGFloat(i - 1) * (circleRadius * 2 + spacing),
                    y: rect.height / 2.0
                )
                
                metaball(&path, prevCenter, circleRadius, center, circleRadius)
            }
        }
        
        return path
    }
}

struct WaveIndicatorShape: Shape {
    var tabCount: Int
    var circleRadius: CGFloat = 40
    
    var oldIndicator: CGFloat
    var oldIndicatorTarget: CGFloat
    var newIndicator: CGFloat
    var newIndicatorTarget: CGFloat
    
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let spacing = (rect.width - circleRadius * CGFloat(tabCount) * 2) / CGFloat(tabCount - 1)
        
        let oldCenter = CGPoint(
            x: circleRadius + oldIndicator * (circleRadius * 2 + spacing),
            y: rect.height / 2.0
        )
        
        let distance = abs(oldIndicatorTarget - newIndicatorTarget)
        let oldIndicatorRadius = max(0.5, 1 - abs(oldIndicatorTarget - oldIndicator) / distance) * circleRadius
        let newIndicatorRadius = max(0.5, 1 - abs(newIndicatorTarget - newIndicator) / distance) * circleRadius
        
        path.move(to: oldCenter)
        path.addArc(
            center: oldCenter,
            radius: oldIndicatorRadius,
            startAngle: Angle.zero,
            endAngle: Angle(degrees: 360),
            clockwise: true
        )
        
        let newCenter = CGPoint(
            x: circleRadius + newIndicator * (circleRadius * 2 + spacing),
            y: rect.height / 2.0
        )
        
        path.move(to: newCenter)
        path.addArc(
            center: newCenter,
            radius: newIndicatorRadius,
            startAngle: Angle.zero,
            endAngle: Angle(degrees: 360),
            clockwise: true
        )
        
        if (oldIndicator < newIndicator) {
            metaball(&path, oldCenter, oldIndicatorRadius, newCenter, newIndicatorRadius)
        } else {
            metaball(&path, newCenter, newIndicatorRadius, oldCenter, oldIndicatorRadius)
        }
        
        return path
    }
    
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get {
            AnimatablePair(oldIndicator, newIndicator)
        }
        set {
            oldIndicator = newValue.first
            newIndicator = newValue.second
        }
    }
    
}


@resultBuilder
class WaveTabsFunctionBuilder {
    static func buildBlock(_ children: any View...) -> [AnyView] {
        var tabs: [AnyView] = []
        
        for child in children {
            tabs.append(AnyView(child))
        }
        
        return tabs
    }
    
}

struct WaveTabView: View {
    let duration: CGFloat = 0.3
    
    @State var oldIndicator: CGFloat = 0
    @State var newIndicator: CGFloat = 0
    @State var oldIndicatorTarget: CGFloat = 1
    @State var newIndicatorTarget: CGFloat = 0
    
    @Binding var selectedTab: Int
    @State var previousTab: Int = 0
    
    @State var tabsHeight: CGFloat = 0
    
    var tabs: () -> [AnyView]
    
    init(selectedTab: Binding<Int>, @WaveTabsFunctionBuilder tabs: @escaping () -> [AnyView]) {
        self.tabs = tabs
        self._selectedTab = selectedTab
    }
    
    var body: some View {
        GeometryReader { geometry in
            let tabs = self.tabs()
            let radius = geometry.size.width / CGFloat(tabs.count * 2) * 1.3
            
            let tabsCount = CGFloat(tabs.count)
            let spacesCount = CGFloat(tabs.count - 1)
            let spacing: CGFloat = (geometry.size.width - radius * tabsCount * 2) / spacesCount
            
            VStack {
                ZStack(alignment: .leading) {
                    WaveTabBarShape(tabCount: tabs.count, circleRadius: radius)
                        .fill(Color.darkGray)
                        .frame(width: geometry.size.width, height: radius * 2)
                    WaveIndicatorShape(
                        tabCount: tabs.count,
                        circleRadius: radius,
                        oldIndicator: oldIndicator,
                        oldIndicatorTarget: oldIndicatorTarget,
                        newIndicator: newIndicator,
                        newIndicatorTarget: newIndicatorTarget
                    )
                    .fill(.white)
                    .frame(width: geometry.size.width, height: radius * 2)
                    .drawingGroup()
                    ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                        let iconColor: Color = (index == selectedTab) ? Color.veryDarkGray : Color.lightGray
                        
                        Button(action: {
                            if selectedTab == index {
                                return
                            }
                            
                            previousTab = selectedTab
                            
                            let slideDuration = self.duration * CGFloat(abs(index - previousTab));
                            let slideShift = self.duration / 2
                            
                            oldIndicatorTarget = CGFloat(previousTab)
                            newIndicatorTarget = CGFloat(index)
                            
                            withAnimation(.easeInOut(duration: slideDuration)) {
                                selectedTab = index
                                newIndicator = CGFloat(index)
                            }
                            withAnimation(.easeInOut(duration: slideDuration).delay(slideShift)) {
                                oldIndicator = CGFloat(index)
                            }
                        }) {
                            tab.frame(width: radius * 2, height: radius * 2)
                        }
                        .foregroundColor(iconColor)
                        .font(.system(size: 30))
                        .frame(width: radius * 2, height: radius * 2)
                        .offset(x: CGFloat(index) * (radius * 2 + spacing))
                    }
                }
            }
            .frame(width: geometry.size.width)
            .onAppear {
                tabsHeight = radius * 2
            }

            .onChange(of: geometry.size.width) { _ in
                let radius = geometry.size.width / CGFloat(tabs.count * 2) * 1.3
                
                if(radius * 2 > tabsHeight){
                    tabsHeight = radius * 2
                }
            }
            .border(Color.red)
        }
        .frame(height: tabsHeight)
    }
}

struct WaveTabView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewView()
    }
    
    struct PreviewView: View {
        @State var selectedTab: Int = 0
        
        var body: some View {
            VStack {
                WaveTabView(selectedTab: $selectedTab) {
                    Image(systemName: "house.fill")
                    Image(systemName: "gearshape.fill")
                    Image(systemName: "aqi.medium")
                    Image(systemName: "person.fill")
                }.background(Color.veryDarkGray)
                Text("selected tab: \(selectedTab)")
            }
        }
    }
}
