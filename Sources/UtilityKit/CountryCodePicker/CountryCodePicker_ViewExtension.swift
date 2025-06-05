//
//  CountryCodePicker_ViewExtension.swift
//  UtilityKit
//
//  Created by Apple on 04/06/25.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func countryCodePicker(isPresented: Binding<Bool>, selectedCountry: Binding<CountryModel?>)-> some View {
        self
            .sheet(isPresented: isPresented) {
                CountryPicker(isPresented: isPresented, selectedCountry: selectedCountry)
                    .presentationDetents([.fraction(0.999)])
            }
    }
}
