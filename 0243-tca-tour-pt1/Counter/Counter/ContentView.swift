//
//  ContentView.swift
//  Counter
//
//  Created by Leo on 1/24/24.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    var body: some View {
        Form {
            Section {
                Text("0")

                Button("Decrement") {

                }
                Button("Increment") {

                }
            }
        }
        Section {
            Button("Get Fact") {

            }
            Text("Some fact")
        }

        Section {
            Button("Stop Timer") {

            }
            Button("Start Timer") {

            }
        }


    }
}

#Preview {
    ContentView()
}
