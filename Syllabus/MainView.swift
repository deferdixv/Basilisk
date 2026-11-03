    //
    //  MainView.swift
    //  Syllabus
    //

    import SwiftUI
    import BasiliskCore
    import BasiliskUI

    struct MainView: View {

        @Environment(SyllabusStore.self) private var store

        @State private var section: AppSection = .syllabus
        @State private var isEditMode: Bool = false
        @State private var selectedPlanTab: PlanTab = .sessions

        var body: some View {
            NavigationSplitView {
                MainSidebar(selection: $section)
                    .navigationSplitViewColumnWidth(
                        min: 200,
                        ideal: 220,
                        max: 320
                    )
            } detail: {
                detailContent
                    .padding(.horizontal, BasiliskLayout.detailOuterPadding)
                    .padding(.vertical, BasiliskLayout.detailOuterPadding)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .navigationTitle(section.rawValue)
                    .toolbar {
                        ToolbarItem(placement: .navigation) {
                            HStack(spacing: BasiliskSpacing.sm) {
                                Button { } label: {
                                    Image(systemName: "chevron.left")
                                }
                                .disabled(true)

                                Button { } label: {
                                    Image(systemName: "chevron.right")
                                }
                                .disabled(true)
                            }
                        }

                        if section == .plan {
                            ToolbarItem(placement: .principal) {
                                TabSwitcher(selection: $selectedPlanTab, compact: true)
                            }
                        }

                        ToolbarItemGroup(placement: .primaryAction) {
                            Button {
                                isEditMode.toggle()
                            } label: {
                                Image(systemName: isEditMode ? "checkmark.circle.fill" : "pencil.circle")
                            }
                            .tint(isEditMode ? BasiliskColor.royalBlue : nil)
                            .help(isEditMode ? "Bearbeiten beenden" : "Bearbeiten")
                            
                            Button {
                                store.syncWithFinder()
                            } label: {
                                Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                            }
                            .help("Mit Finder synchronisieren")

                            Button {
                                // Session starten — Stufe C2
                            } label: {
                                HStack(spacing: BasiliskSpacing.md) {
                                    Image(systemName: "star.fill")
                                    Text("Per Aspera ad Astra")
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(BasiliskColor.brand)
                        }
                    }
            }
        }

        // MARK: - Detail-Switch

        @ViewBuilder
        private var detailContent: some View {
            switch section {
            case .syllabus:
                SyllabusScreen(isEditMode: $isEditMode)

            case .plan:
                PlanScreen(selectedTab: $selectedPlanTab)

            default:
                PlaceholderScreen(for: section)
            }
        }
    }

    // MARK: - Placeholder

    private struct PlaceholderScreen: View {
        let forSection: AppSection

        init(for section: AppSection) { self.forSection = section }

        var body: some View {
            VStack(spacing: BasiliskSpacing.lg) {
                Image(systemName: forSection.icon)
                    .font(.system(size: 42, weight: .light))
                    .foregroundStyle(BasiliskColor.textMuted)
                Text(forSection.rawValue)
                    .font(BasiliskFont.sectionTitle)
                    .foregroundStyle(BasiliskColor.text)
                Text("Folgt in einer späteren Iteration.")
                    .font(BasiliskFont.body)
                    .foregroundStyle(BasiliskColor.textMuted)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(BasiliskColor.background)
        }
    }

    // MARK: - PlanScreen (Platzhalter)

    private struct PlanScreen: View {
        @Binding var selectedTab: PlanTab

        var body: some View {
            VStack(spacing: BasiliskSpacing.lg) {
                Image(systemName: "calendar")
                    .font(.system(size: 42, weight: .light))
                    .foregroundStyle(BasiliskColor.textMuted)
                Text("PlanView — \(selectedTab.rawValue)")
                    .font(BasiliskFont.sectionTitle)
                    .foregroundStyle(BasiliskColor.text)
                Text("Wird in Stufe C2 gebaut.")
                    .font(BasiliskFont.body)
                    .foregroundStyle(BasiliskColor.textMuted)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(BasiliskColor.background)
        }
    }
