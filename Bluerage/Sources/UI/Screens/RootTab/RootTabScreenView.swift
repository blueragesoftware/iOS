import SwiftUI

struct RootTabScreenView: View {

    var body: some View {
        if #available(iOS 18, *) {
            ModernTabView()
        } else {
            StandardTabView()
        }
    }

}

@available(iOS 18, *)
private struct ModernTabView: View {

    @State var selectedTab: RootTabDestinations = .agentsList

    var body: some View {
        TabView(selection: self.$selectedTab) {
            ForEach(RootTabDestinations.tabs) { tab in
                Tab(value: tab) {
                    tab
                } label: {
                    Image(systemName: tab.icon)
                }
            }
        }
    }

}

private struct StandardTabView: View {

    @State var selectedTab: RootTabDestinations = .agentsList

    var body: some View {
        TabView(selection: self.$selectedTab) {
            ForEach(RootTabDestinations.tabs) { tab in
                tab
                    .tabItem {
                        Image(systemName: tab.icon)
                    }
                    .tag(tab)
            }
        }
    }

}
