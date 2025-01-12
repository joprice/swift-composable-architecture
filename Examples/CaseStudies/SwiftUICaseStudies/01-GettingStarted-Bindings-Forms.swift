import ComposableArchitecture
import SwiftUI

private let readMe = """
  This file demonstrates how to handle two-way bindings in the Composable Architecture using \
  binding state and actions.

  Binding state and actions allow you to safely eliminate the boilerplate caused by needing to \
  have a unique action for every UI control. Instead, all UI bindings can be consolidated into a \
  single `binding` action that holds onto a `BindingAction` value, and all binding state can be \
  safeguarded with the `BindingState` property wrapper.

  It is instructive to compare this case study to the "Binding Basics" case study.
  """

// MARK: - Feature domain

@Reducer
struct BindingForm {
  @ObservableState
  struct State: Equatable {
    var sliderValue = 5.0
    var stepCount = 10
    var text = ""
    var toggleIsOn = false
  }

  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case resetButtonTapped
  }

  var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(\.stepCount):
        state.sliderValue = .minimum(state.sliderValue, Double(state.stepCount))
        return .none

      case .binding:
        return .none

      case .resetButtonTapped:
        state = State()
        return .none
      }
    }
  }
}

// MARK: - Feature view

struct BindingFormView: View {
  @Bindable var store = Store(initialState: BindingForm.State()) {
    BindingForm()
  }

  var body: some View {
    Form {
      Section {
        AboutView(readMe: readMe)
      }

      HStack {
        TextField("Type here", text: $store.text)
          .disableAutocorrection(true)
          .foregroundStyle(store.toggleIsOn ? Color.secondary : .primary)
        Text(alternate(store.text))
      }
      .disabled(store.toggleIsOn)

      Toggle("Disable other controls", isOn: $store.toggleIsOn.resignFirstResponder())

      Stepper(
        "Max slider value: \(store.stepCount)",
        value: $store.stepCount,
        in: 0...100
      )
      .disabled(store.toggleIsOn)

      HStack {
        Text("Slider value: \(Int(store.sliderValue))")

        Slider(value: $store.sliderValue, in: 0...Double(store.stepCount))
          .tint(.accentColor)
      }
      .disabled(store.toggleIsOn)

      Button("Reset") {
        store.send(.resetButtonTapped)
      }
      .tint(.red)
    }
    .monospacedDigit()
    .navigationTitle("Bindings form")
  }
}

private func alternate(_ string: String) -> String {
  string
    .enumerated()
    .map { idx, char in
      idx.isMultiple(of: 2)
        ? char.uppercased()
        : char.lowercased()
    }
    .joined()
}

// MARK: - SwiftUI previews

struct BindingFormView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      BindingFormView(
        store: Store(initialState: BindingForm.State()) {
          BindingForm()
        }
      )
    }
  }
}
