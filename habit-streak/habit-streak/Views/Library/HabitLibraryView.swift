//
//  HabitLibraryView.swift
//  habit-streak
//
//  PRD §5.3 — library sheet: search, chips, sections, sticky footer.
//

import SwiftUI

struct HabitLibraryView: View {
    var onClose: () -> Void
    var onPickTemplate: (HabitCreationPrefill) -> Void
    var onCreateCustom: () -> Void

    @State private var searchText: String = ""
    @State private var selectedCategory: HabitTemplateCategory = .popular

    private var searchQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// PRD §5.3 — search spans all categories; otherwise show selected chip category.
    private var visibleSections: [(category: HabitTemplateCategory, templates: [HabitTemplate])] {
        if searchQuery.isEmpty {
            let list: [HabitTemplate] = HabitTemplateLibrary.templates(in: selectedCategory)
            return [(selectedCategory, list)]
        }
        let matches: [HabitTemplate] = HabitTemplateLibrary.search(searchQuery)
        return HabitTemplateCategory.allCases.compactMap { cat in
            let sub: [HabitTemplate] = matches.filter { $0.category == cat }
            return sub.isEmpty ? nil : (cat, sub)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                AppColor.bgPrimary.ignoresSafeArea()

                VStack(spacing: 0) {
                    searchField
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    chipScroll
                        .padding(.vertical, 12)

                    ScrollView {
                        Group {
                            if visibleSections.isEmpty {
                                Text("No templates match your search.")
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundStyle(AppColor.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 24)
                            } else {
                                VStack(alignment: .leading, spacing: 20) {
                                    ForEach(visibleSections, id: \.category) { section in
                                        VStack(alignment: .leading, spacing: 12) {
                                            if searchQuery.isEmpty {
                                                sectionHeader(for: section.category)
                                            } else {
                                                Text(section.category.sectionHeading)
                                                    .font(.system(size: 17, weight: .semibold))
                                                    .foregroundStyle(AppColor.textPrimary)
                                                    .padding(.horizontal, 16)
                                            }
                                            if section.templates.isEmpty {
                                                Text("No templates in this category.")
                                                    .font(.system(size: 15, weight: .regular))
                                                    .foregroundStyle(AppColor.textSecondary)
                                                    .padding(.horizontal, 16)
                                            } else {
                                                LazyVStack(spacing: 12) {
                                                    ForEach(section.templates) { template in
                                                        TemplateCardView(template: template) {
                                                            onPickTemplate(template.toPrefill())
                                                        }
                                                    }
                                                }
                                                .padding(.horizontal, 16)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 100)
                    }
                }

                footerButton
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                    .background(
                        LinearGradient(
                            colors: [AppColor.bgPrimary.opacity(0), AppColor.bgPrimary],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 88)
                        .allowsHitTesting(false)
                    )
            }
            .navigationTitle("Habit Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColor.bgPrimary, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { onClose() }
                        .foregroundStyle(AppColor.textPrimary)
                }
            }
        }
    }

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColor.textSecondary)
            TextField("Search templates", text: $searchText)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(AppColor.textPrimary)
                .textFieldStyle(.plain)
                .accessibilityLabel("Search templates")
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(AppColor.bgSecondary))
    }

    private var chipScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(HabitTemplateCategory.allCases) { category in
                    CategoryChipView(
                        title: category.chipTitle,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func sectionHeader(for category: HabitTemplateCategory) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(category.sectionHeading)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)
            Text(category.sectionSubheading)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(AppColor.textSecondary)
        }
        .padding(.horizontal, 16)
    }

    private var footerButton: some View {
        Button {
            onCreateCustom()
        } label: {
            Text("Create a custom habit")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .liquidGlass(in: Capsule(), interactive: true, tint: AppColor.accentBlue, fallback: AppColor.accentBlue)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Create a custom habit")
    }
}
