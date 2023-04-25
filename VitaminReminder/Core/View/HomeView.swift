//
//  HomeView.swift
//  VitaminReminder
//
//  Created by Orina on 21.02.2023.
//

import SwiftUI


enum DragStatus{
    case completed
    case current
    case hidden
}

extension DragStatus {
    func rotation() -> Angle {
        switch self {
        case .current:
            return Angle.zero
        case .completed:
            return Angle.degrees(-90 * 0.65)
        case .hidden:
            return Angle.degrees(90 * 0.65)
        }
    }
    
    func translation(radius: CGFloat) -> CGFloat {
        return rotation().radians * radius
    }
}


struct DragsView: View {
    var backgroundColor: Color
    var status : DragStatus
    var completed: () -> Void
    
    @State var hidden: Bool = false
    
    init(backgroundColor: Color, status: DragStatus, completed: @escaping () -> Void) {
        self.backgroundColor = backgroundColor
        self.status = status
        self.completed = completed
    }
    
    var body: some View {
        GeometryReader() { geometry in
            VStack(alignment: .leading){
                HStack(alignment: .bottom){
                    StrokeText("2", strokeWidth: 5.0, fontSize: 160, foregroundColor: backgroundColor)
                        .frame(width: 120, height: 140)
                    Text("tabs")
                        .font(.system(size: 48, weight: .bold))
                }
                Text("Omega-3")
                    .font(.system(size: 24)).padding(.bottom, 2)
                    .padding(.leading, 16)
                HStack(){
                    Text("08:00 AM")
                        .font(.system(size: 30, weight: .semibold))
                        .padding(.leading, 16).padding(.trailing, 20)
                    Button(action:{
                        withAnimation(.linear(duration: 0.8).speed(1.5)){
                            completed()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            hidden = true
                        }
                    }, label: {Circle().frame(width: 48, height: 48)}).foregroundColor(.mint)
                    
                }
            }
            .frame(width: geometry.size.width - 20, height: geometry.size.width - 20)
            .background(backgroundColor)
            .cornerRadius(.infinity)
            .padding(10)
            .rotationEffect(status.rotation())
            .offset(x: status.translation(radius: geometry.size.width - 20), y: 0)
            .opacity(hidden ? 0.0 : 1.0)
        }.aspectRatio(contentMode: .fit)
        
    }
}

struct Item: Identifiable {
    let id = UUID()
    
    var value: Int
    // Other properties...
    var loc: CGRect = .zero
}

struct DatePicker: View {
    var dateCompleted: Bool
    @State private var ruler: CGFloat!
    
    @State private var items = (0..<10).map { Item(value: $0) }
    @State private var centredItem: Item!
    
    var body: some View {
        
        
        VStack(spacing: -6) {
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach($items) { $item in
                        VStack() {
                            Text("\(item.value)").font(.system(size: 24, weight: .bold, design: .default)).foregroundColor(.black).frame(width: 80, height: 80).background(centredItem != nil && centredItem.id == item.id ? dateCompleted ? .blue : .mint : dateCompleted ? .white.opacity(0.3) : .gray.opacity(0.1)).cornerRadius(80)
                            Text("Fr").foregroundColor(centredItem != nil && centredItem.id == item.id ? dateCompleted ? .black : .white : dateCompleted ? .white : .black).padding([.horizontal, .bottom], 24)
                        }
                        .background(centredItem != nil && centredItem.id == item.id ? dateCompleted ? .white : .black : dateCompleted ? .black : .white)
                        .cornerRadius(80)
                        
                        .measureLoc { loc in
                            item.loc = loc
                            
                            if let ruler = ruler {
                                if item.loc.maxX >= ruler && item.loc.minX <= ruler {
                                    withAnimation(.easeOut) {
                                        centredItem = item
                                    }
                                }
                                
                                // Move outsides
                                if ruler <= items.first!.loc.minX ||
                                    ruler >= items.last!.loc.maxX {
                                    withAnimation(.easeOut) {
                                        centredItem = nil
                                    }
                                }
                            }
                            
                        }
                    }
                }
                // Extra space above and below
                .padding(.horizontal, ruler)
            }
            Rectangle()
                .frame(width: 1, height: 20)
                .foregroundColor(.clear)
                .measureLoc { loc in
                    ruler = (loc.minX + loc.maxX) / 2
                }
            
            
        }
        .padding(0)
        .frame(maxWidth: .infinity, maxHeight: 160)
    }
}

struct LocKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}

extension View {
    func measureLoc(_ perform: @escaping (CGRect) ->()) -> some View {
        overlay(GeometryReader { geo in
            Color.clear
                .preference(key: LocKey.self, value: geo.frame(in: .global))
        }.onPreferenceChange(LocKey.self, perform: perform))
    }
}

struct HomeView: View {
    var morningColor: Color = Color(hue: 0.1639, saturation: 1, brightness: 1)
    var dayColor: Color = Color.pink
    var eveningColor: Color = Color.green
    
    @State var morningStatus: DragStatus = .current
    @State var dayStatus: DragStatus = .hidden
    @State var eveningStatus: DragStatus = .hidden
    @State var dateCompleted: Bool = false
    @State var shakeNumber: CGFloat = 0.0
    
    var body: some View {
        ZStack(alignment: .bottom){
            ZStack(){
                DragsView(backgroundColor: eveningColor, status: eveningStatus) {
                    withAnimation(){
                        dateCompleted = true
                    }
                    withAnimation(){
                        shakeNumber = 20.0
                    }
                    
                }
                DragsView(backgroundColor: dayColor, status: dayStatus) {
                    dayStatus = .completed
                    eveningStatus = .current
                    
                }
                DragsView(backgroundColor: morningColor, status: morningStatus) {
                    morningStatus = .completed
                    dayStatus = .current
                }
            }.background(
                Circle()
                    .foregroundColor(.white)
                    .scaleEffect(4)
                
            ).offset(y: -80).scaleEffect(dateCompleted ? 0.0 : 1.0)
            ZStack(alignment: .leading){
                VStack(alignment: .leading){
                    StrokeText("All", strokeColor: .white, strokeWidth: 5.0, fontSize: 160, foregroundColor: .black)
                        .frame(width: 120, height: 140).animation(.linear(duration: 4.0).delay(2.5), value: shakeNumber)
                        .modifier(ShakeEffect(shakeNumber: shakeNumber))
                    Text("done")
                        .font(.system(size: 48, weight: .bold)).foregroundColor(.white).animation(.linear(duration: 4.0).delay(2.5), value: shakeNumber)
                        .modifier(ShakeEffect(shakeNumber: shakeNumber))
                }
            }.offset( y: -200).scaleEffect(dateCompleted ? 1.0 : 0.0).animation(Animation.default.delay(0.5), value: dateCompleted)
            GeometryReader() { geometry in
                ZStack(alignment: .center){
                    Text("Biotin").frame(width: 84, height: 84).background(dayColor).cornerRadius(.infinity).offset(x: -geometry.size.width * 0.4, y: -60)
                    Text("omega-3").frame(width: 96, height: 96).background(morningColor).cornerRadius(.infinity).offset(x: geometry.size.width * 0.36, y: 120)
                    Text("iron").frame(width: 96, height: 96).background(eveningColor).cornerRadius(.infinity).offset(x: geometry.size.width * 0.36, y: -140)
                }.scaleEffect(dateCompleted ? 1.0 : 0.0).animation(Animation.default.delay(0.8), value: dateCompleted).frame(maxWidth: .infinity, maxHeight: .infinity)
            }.aspectRatio(contentMode: .fit).offset(y: -100)
            VStack() {
                HStack(alignment: .top){
                    VStack() {
                        Text("Hello,")
                            .font(.system(size: 32, weight: .bold, design: .default)).foregroundColor(.gray)
                        Text("Alice ")
                            .font(.system(size: 36, weight: .bold, design: .default)).foregroundColor(dateCompleted ? .white : .black)
                        
                        
                    }.padding(16)
                    Spacer()
                    Button(action: {
                        print("button pressed")
                        
                    }) {
                        Image("search_icon")
                            .resizable()
                            .frame(width: 32.0, height: 32.0)
                        
                    }.padding(16)
                    
                }.padding(0)
                DatePicker(dateCompleted: dateCompleted)
                Spacer()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().background(.black)
    }
}
