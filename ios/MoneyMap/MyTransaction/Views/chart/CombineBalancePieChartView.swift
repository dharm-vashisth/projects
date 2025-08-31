//
//  CombineBalancePieChartView.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 20/08/25.
//

import SwiftUI
import Charts

struct CombineBalancePieChartView: View {
    var segments: [BalanceSegment]

    var body: some View {
        Chart(segments) { segment in
                   SectorMark(
                       angle: .value("Amount", segment.value),
                       innerRadius: .ratio(0.5),
                       angularInset: 2.0
                   )
                   .foregroundStyle(by: .value("Type", segment.label))
                   
                   // 👇 Add annotation for percentage
                   .annotation(position: .overlay) {
                       Text("\(segment.label): \(segment.percentage, specifier: "%.2f")%")
                           .font(.caption)
                           .foregroundColor(.primary)
                           .bold()
                   }
               }
               .chartLegend(.visible)
               .frame(height: 300)
               .padding()
    }
}
