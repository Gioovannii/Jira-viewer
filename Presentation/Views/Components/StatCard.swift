//
//  StatCard.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// Reusable statistics card
struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HStack(spacing: 20) {
        StatCard(title: "Total", value: "25", color: .blue)
        StatCard(title: "Done", value: "18", color: .green)
        StatCard(title: "In Progress", value: "5", color: .orange)
        StatCard(title: "To Do", value: "2", color: .gray)
    }
    .padding()
}
