//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Apple on 01/06/25.
//

import SwiftUI

struct Chip: Identifiable {
    var id: String = UUID().uuidString
    var name: String
}

let mockChips: [Chip] = [
    .init(name: "Apple"),
    .init(name: "Google"),
    .init(name: "Microsoft"),
    .init(name: "Amazon"),
    .init(name: "Facebook"),
    .init(name: "Twitter"),
    .init(name: "Netflix"),
    .init(name: "Youtube"),
    .init(name: "Instagram"),
    .init(name: "Snapchat"),
    .init(name: "Pinterest"),
    .init(name: "Reddit"),
    .init(name: "TikTok"),
    .init(name: "Uber"),
    .init(name: "Spotify")
]

@available(iOS 16.0, *)
/// A custom layout that arranges its child views in horizontal rows,
/// wrapping to the next line when exceeding the container width.
/// Similar to a "chip" or tag layout.
public struct ChipLayout: Layout {
    
    /// The horizontal alignment of views within each row.
    var alignment: Alignment = .center
    
    /// The spacing between items and between rows.
    var spacing: CGFloat = 10
    
    /// Creates a chip-style layout with custom alignment and spacing.
    ///
    /// - Parameters:
    ///   - alignment: The horizontal alignment for each row (.leading, .center, .trailing).
    ///   - spacing: The spacing between views and between rows.
    public init(alignment: Alignment, spacing: CGFloat) {
        self.alignment = alignment
        self.spacing = spacing
    }
    
    /// Computes the overall size required to fit all subviews within a given width,
    /// wrapping to new rows as needed.
    ///
    /// - Parameters:
    ///   - proposal: The proposed size for the layout.
    ///   - subviews: The views to be laid out.
    ///   - cache: A placeholder for caching layout calculations (unused).
    /// - Returns: The total size needed to fit all subviews.
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 0
        var height: CGFloat = 0
        
        let rows = generateRows(maxWidth, proposal, subviews)
        
        for (index, row) in rows.enumerated() {
            if index == (rows.count - 1) {
                height += row.maxHeight(proposal)
            } else {
                height += row.maxHeight(proposal) + spacing
            }
        }
        
        return .init(width: maxWidth, height: height)
    }
    
    /// Places the subviews within the given bounds, aligning and wrapping them into rows.
    ///
    /// - Parameters:
    ///   - bounds: The area available for laying out subviews.
    ///   - proposal: The proposed size for each subview.
    ///   - subviews: The views to be laid out.
    ///   - cache: A placeholder for caching layout calculations (unused).
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var origin = bounds.origin
        let maxWidth = bounds.width
        let rows = generateRows(maxWidth, proposal, subviews)
        
        for row in rows {
            // Calculate starting X based on alignment
            let leading: CGFloat = bounds.maxX - maxWidth
            let trailing = bounds.maxX - (row.reduce(CGFloat.zero) { partialResult, view in
                let width = view.sizeThatFits(proposal).width
                if view == row.last {
                    return partialResult + width
                }
                return partialResult + width + spacing
            })
            let center = (trailing + leading) / 2
            
            origin.x = (alignment == .leading ? leading : alignment == .trailing ? trailing : center)
            
            for view in row {
                let viewSize = view.sizeThatFits(proposal)
                view.place(at: origin, proposal: proposal)
                origin.x += (viewSize.width + spacing)
            }
            
            origin.y += (row.maxHeight(proposal) + spacing)
        }
    }
    
    /// Splits the subviews into rows based on available width and spacing.
    ///
    /// - Parameters:
    ///   - maxWidth: The maximum width for a single row.
    ///   - proposal: The proposed size to measure each subview.
    ///   - subviews: The views to organize into rows.
    /// - Returns: A 2D array of subviews organized into rows.
    public func generateRows(_ maxWidth: CGFloat, _ proposal: ProposedViewSize, _ subviews: Subviews) -> [[LayoutSubviews.Element]] {
        var row: [LayoutSubviews.Element] = []
        var rows: [[LayoutSubviews.Element]] = []
        var origin = CGRect.zero.origin
        
        for view in subviews {
            let viewSize = view.sizeThatFits(proposal)
            
            if (origin.x + viewSize.width + spacing) > maxWidth {
                rows.append(row)
                row.removeAll()
                origin.x = 0
                row.append(view)
                origin.x += (viewSize.width + spacing)
            } else {
                row.append(view)
                origin.x += (viewSize.width + spacing)
            }
        }
        
        if !row.isEmpty {
            rows.append(row)
            row.removeAll()
        }
        
        return rows
    }
}

@available(iOS 16.0, *)
public extension [LayoutSubviews.Element] {
    
    /// Returns the maximum height among all views in the array.
    ///
    /// - Parameter proposal: The proposed size for measuring each subview.
    /// - Returns: The tallest height found in the array, or 0 if empty.
    func maxHeight(_ proposal: ProposedViewSize) -> CGFloat {
        return self.compactMap { view in
            return view.sizeThatFits(proposal).height
        }.max() ?? 0
    }
}
