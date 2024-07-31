//
//  ContentView.swift
//  HelloWorld
//
//  Created by Artem Shmelev on 01.03.2024.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

struct ContentView: View {
    @AppStorage("inputCurrency") var inputCurrency: Currency = .EUR
    @AppStorage("outputCurrency") var outputCurrency: Currency = .USD
    @State private var inputString: String = ""
    @State private var outputString: String = ""
    @State private var showPopover = false
    
    let helpMessage = """
    This app is for converting amount between currencies.
    Enter number to convert, currencies and press "Convert".
    
    Application uses exchange rates published by the European Central Bank.
    """
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("", systemImage: "info.circle") {
                    showPopover = true
                }
                .font(.title2)
                .foregroundColor(.gray)
                .padding()
                .popover(isPresented: $showPopover) {
                    Text(helpMessage)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(height: 200)
                        .presentationCompactAdaptation(.none)
                        .padding()
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("convert from")
                        .foregroundStyle(.gray)
                        .font(.subheadline)
                    
                    Menu {
                        Picker("InPicker", selection: $inputCurrency) {
                            ForEach(Currency.allCases) { currency in
                                Label(currency.rawValue,
                                      systemImage: GetCurrencyIcon(currency))
                            }
                        }
                    } label: {
                        Label(inputCurrency.rawValue,
                              systemImage: GetCurrencyIcon(inputCurrency))
                        .font(.title)
                        Image(systemName: "chevron.up.chevron.down")
                    }
                }
                .padding()
                
                VStack(alignment: .leading) {
                    Text("convert to")
                        .foregroundStyle(.gray)
                        .font(.subheadline)

                    Menu {
                        Picker("OutPicker", selection: $outputCurrency) {
                            ForEach(Currency.allCases) { currency in
                                Label(currency.rawValue,
                                      systemImage: GetCurrencyIcon(currency))
                            }
                        }
                    } label: {
                        Label(outputCurrency.rawValue,
                              systemImage: GetCurrencyIcon(outputCurrency))
                        .font(.title)
                        Image(systemName: "chevron.up.chevron.down")
                    }
                }
                .padding()
            }
            .padding()
            
            HStack {
                TextField("Enter number...", text: $inputString)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .font(.largeTitle)
                    .padding()
                    .onReceive(Just(inputString)) { newValue in
                        let filtered = newValue.filter { Set("0123456789.").contains($0) }
                        if filtered != newValue {
                            inputString = filtered
                        }
                    }
                    .onReceive(Just(inputString)) { newValue in
                        if newValue.count > 9 {
                            inputString = String(newValue.prefix(9))
                        }
                    }
                if !inputString.isEmpty {
                    Button {
                        inputString = ""
                        outputString = ""
                    } label: {
                        Image(systemName: "multiply.circle.fill")
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    }
                    .padding(.trailing, 10)
                }
            }
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.blue, lineWidth: 1)
            )
            .padding()
            
            Button("Convert") {
                if !inputString.isEmpty {
                    if inputCurrency == outputCurrency {
                        outputString = inputString
                    } else {
                        CurrencyApi().convert(
                            inputCurrency: inputCurrency,
                            inputAmount: inputString,
                            outputCurrency: outputCurrency) { convertResult in
                                outputString = String(convertResult)
                            }
                    }
                }
            }
            .font(.title)
            .padding()
            .buttonStyle(.borderedProminent)
            
            HStack {
                TextField("Result here...", text: $outputString)
                    .multilineTextAlignment(.center)
                    .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    .font(.largeTitle)
                    .padding()
                if !outputString.isEmpty {
                    Button {
                        let clipboard = UIPasteboard.general
                        clipboard.setValue(
                            outputString,
                            forPasteboardType: UTType.plainText.identifier
                        )
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.title)
                    }
                    .padding(.trailing, 10)
                }
            }
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.blue, lineWidth: 1)
            )
            .padding()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
