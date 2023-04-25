//
//  Tabs.swift
//  VitaminReminder
//
//  Created by Orina on 22.02.2023.
//

import SwiftUI


struct TabItemData {
    let image: String
}

struct TabItemView: View {
    let data: TabItemData
    let isSelected: Bool
    
    var body: some View {
        
        VStack {
            Image(systemName: data.image).foregroundColor(.white).font(.system(size: 22))
        }.frame(width: 96, height: 96).background(isSelected ? .black : .gray).cornerRadius(96)
    }
}

struct TabBottomView: View {
    
    let tabbarItems: [TabItemData]
    var height: CGFloat = 48
    var width: CGFloat = UIScreen.main.bounds.width - 32
    @Binding var selectedIndex: Int
    
    var body: some View {
        ZStack(alignment: .center){
            HStack{}.frame(width: width, height: height)
                .background(.gray)
                .cornerRadius(13)
            HStack(spacing: -6) {
                
                ForEach(tabbarItems.indices, id: \.self) { index in
                    let item = tabbarItems[index]
                    Button(action: {
                        self.selectedIndex = index
                    }, label: {
                        let isSelected = selectedIndex == index
                        TabItemView(data: item, isSelected: isSelected)
                    }).background(.gray).cornerRadius(96)
                }
            }
            .frame(width: width)
        }
    }
}

struct CustomTabView<Content: View>: View {
    
    let tabs: [TabItemData]
    @Binding var selectedIndex: Int
    @ViewBuilder let content: (Int) -> Content
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedIndex) {
                ForEach(tabs.indices, id: \.self) { index in
                    content(index)
                        .tag(index)
                }
            }
            
            VStack {
                Spacer()
                TabBottomView(tabbarItems: tabs, selectedIndex: $selectedIndex)
            }
        }
    }
}

enum TabType: Int, CaseIterable {
    case home = 0
    case menu
    case settings
    case profile
    
    var tabItem: TabItemData {
        switch self {
        case .home:
            return TabItemData(image: "house")
        case .menu:
            return TabItemData(image: "square.grid.2x2.fill")
        case .settings:
            return TabItemData(image: "gearshape.fill")
            
        case .profile:
            return TabItemData(image: "person.fill")
            
        }
    }
    
    struct MyFileView: View {
        var body: some View {
            Text("MyFileView")
        }
        
    }
    
    struct ProfileView: View {
        var body: some View {
            Text("ProfileView")
        }
        
    }
    
    struct SomeView: View {
        var body: some View {
            Text("SomeView")
        }
        
    }
    
    struct MainTabView: View {
        
        @State var selectedIndex: Int = 0
        
        var body: some View {
            CustomTabView(tabs: TabType.allCases.map({ $0.tabItem }), selectedIndex: $selectedIndex) { index in
                let type = TabType(rawValue: index) ?? .home
                getTabView(type: type)
            }
        }
        
        @ViewBuilder
        func getTabView(type: TabType) -> some View {
            switch type {
            case .home:
                HomeView()
            case .menu:
                HomeView()
            case .settings:
                MyFileView()
            case .profile:
                ProfileView()
            }
        }
    }
    
    
    struct Tabs_Previews: PreviewProvider {
        static var previews: some View {
            MainTabView()
        }
    }
}
