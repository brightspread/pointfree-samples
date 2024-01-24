//
//  ContentView.swift
//  Counter
//
//  Created by Leo on 1/24/24.
//

import SwiftUI
import ComposableArchitecture

// TCA 사용 -> 모든 feature로직이 값 타입으로 모델링되고, Single 리듀서 안에서 캡슐화되어있음

struct CounterFeature: Reducer {
    struct State: Equatable {
        var count = 0
        var fact: String?
        var isTimerOn = false
    }

    // type of the actions for the feature
    // case for each thing the user can do in the the UI
    // like button tap whatever
    // 유저가 하는 행동을 literally 하게 표현할 것
    enum Action {
        case decrementButtonTapped
        case factResponse(String)
        case getFactButtonTapped
        case incrementButtonTapped
        case toggleTimerButtonTapped
    }

    // Effect 를 반환해야함
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            // mutate state here
            switch action {
                case .decrementButtonTapped:
                    state.count -= 1
                    state.fact = nil
                    return .none // 바깥 세계에 아무 영향을 주지 않는 effect
                case let .factResponse(fact):
                    state.fact = fact
                    return .none
                case .getFactButtonTapped:
                    //TODO: perform network request
                    // send : 시스템으로 액션을 보낼 수 있게하는 값
                    state.fact = nil
                    return .run { [count = state.count] send in // 이 클로저는 async context
                        let (data, _) = try await URLSession.shared.data(
                            from: URL(string: "http://numbersapi.com/\(count)")!
                        )
                        let fact = String(decoding: data, as: UTF8.self)
                        print(fact)
                        
                        // state.fact = fact // inout parameter 은 캡처될 수 없음
                        // 바꿀 수 없는 건 값타입을 사용하는 비용임

                        // Great guarantee but also cannot simply be mutated

                        // 바꾸려면 Action 사용! 그냥 바꾸는건 안됨!
                        await send(.factResponse(fact))
                    }
                case .incrementButtonTapped:
                    state.count += 1
                    state.fact = nil
                    return .none
                case .toggleTimerButtonTapped:
                    state.isTimerOn.toggle()
                    //TODO: start a timer
                    return .none
            }
        }
    }
}

struct ContentView: View {
    // application은 시간이 지남에 따라 변경되고, 예측할 수 없는 시스템 외부와 상호작용하도록 되어있음
    // 이것이 결국 어딘가에 참조 유형이 필요한 이유임

    // value 타입으로는 모든 것을 할 순 없고,
    // store는 reference type으로 씀
    /// public final class Store<State, Action>
    let store: StoreOf<CounterFeature> // same as "Store<CounterFeature.State, CounterFeature.Action>"

    var body: some View {
        //  observe: { $0 } 는 store의 모든 값을 관찰하겠다
        // 전형적으로 모든 것을 관찰하는 건 옳지 않음
        // 실제로 View에 필요한 것 보다 많은 state를 들고 있음

        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    Text("\(viewStore.count)")

                    Button("Decrement") {
                        viewStore.send(.decrementButtonTapped)
                    }
                    Button("Increment") {
                        viewStore.send(.incrementButtonTapped)
                    }
                }

                Section {
                    Button("Get Fact") {
                        viewStore.send(.getFactButtonTapped)
                    }
                    if let fact = viewStore.fact {
                        Text(fact)
                    }
                }

                Section {
                    if viewStore.isTimerOn {
                        Button("Stop Timer") {
                            viewStore.send(.toggleTimerButtonTapped)
                        }
                    } else {
                        Button("Start Timer") {
                            viewStore.send(.toggleTimerButtonTapped)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView(
        store: Store(
            initialState: CounterFeature.State()) {
                CounterFeature()
                    ._printChanges()
            }
    )
}
