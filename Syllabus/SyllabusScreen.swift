//
//  SyllabusScreen.swift
//  Syllabus
//

import SwiftUI
import BasiliskCore
import BasiliskUI

struct SyllabusScreen: View {

    @Environment(SyllabusStore.self) private var store
    @Binding var isEditMode: Bool
    
    @State private var renameTarget: EditAction?
    @State private var deleteTarget: EditAction?
    @State private var groupTarget: EditAction?

    var body: some View {
        SyllabusView(
            courses: store.courses,
            parts: store.parts,
            chapters: store.chapters,
            subchapters: store.subchapters,
            steps: store.steps,
            progressByCourseID: store.courseProgress,
            selectedCourseIDs: Binding(
                get: { store.selectedCourseIDs },
                set: { store.setCourseSelection($0) }
            ),
            selectedChapterIDs: Binding(
                get: { store.selectedChapterIDs },
                set: { store.setChapterSelection($0) }
            ),
            selectedPartIDs: Binding(
                get: { store.selectedPartIDs },
                set: { store.setPartSelection($0) }
            ),
            isEditMode: isEditMode,
            onAddCourse: { name in
                store.createCourse(named: name)
            },
            onPickUniversityRoot: {
                store.pickAndSetUniversityRoot()
            },
            onAddChapter: { title, courseID in
                store.createChapter(titled: title, in: courseID)
            },
            onAddPart: { _ in
                // Parts-Zusammenfassung via Kontextmenü, kommt in Runde 3
            },
            onAddSubchapter: { title, chapterID in
                store.createSubchapter(titled: title, in: chapterID)
            },
            onEditAction: { action in
                switch action {
                case .deleteChaptersBulk, .deleteChapter, .deleteCourse,
                     .deleteSubchapter, .deletePart:
                    deleteTarget = action
                case .groupChapters:
                    groupTarget = action
                case .renameCourse, .renameChapter, .renameSubchapter, .renamePart:
                    renameTarget = action
                }
            },
            onRevealInFinder: { course in
                store.revealCourseInFinder(course)
            },
            onToggleStep: { step in
                store.toggleStep(step)
            },
            onToggleSubchapter: { sub in
                store.toggleSubchapter(sub)
            },
            onAddStep: { title, subchapterID in
                store.createStep(titled: title, in: subchapterID)
            },
            onPickCourseFolder: { course in
                store.pickAndSetCourseFolder(course)
            },
            onRevealChapterInFinder: { chapter, course in
                store.revealChapterInFinder(chapter, in: course)
            },
            onDeleteStep: { step in
                store.deleteStep(step)
            },
            onUpdateStepNotes: { step, notes in
                store.updateStepNotes(step, notes: notes)
            },
            onAddFileLink: { title, url, stepID in
                store.createFileLink(forStep: stepID, title: title, url: url)
            },
            onDeleteFileLink: { link in
                store.deleteFileLink(link)
            },
        )
        .sheet(item: $renameTarget) { action in
            RenameSheet(
                title: renameSheetTitle(for: action),
                placeholder: "Neuer Titel",
                initialValue: action.currentValue,
                isPresented: Binding(
                    get: { renameTarget != nil },
                    set: { if !$0 { renameTarget = nil } }
                )
            ) { newValue in
                applyRename(action, newValue: newValue)
            }
        }
        .sheet(item: $groupTarget) { action in
            if case .groupChapters(let chapters, _) = action {
                RenameSheet(
                    title: "Zu Teil zusammenfassen",
                    placeholder: "Name des Teils",
                    initialValue: "",
                    isPresented: Binding(
                        get: { groupTarget != nil },
                        set: { if !$0 { groupTarget = nil } }
                    )
                ) { newTitle in
                    applyGroup(chapters: chapters, newTitle: newTitle)
                }
            }
        }
        .alert(
            "Wirklich löschen?",
            isPresented: Binding(
                get: { deleteTarget != nil },
                set: { if !$0 { deleteTarget = nil } }
            ),
            presenting: deleteTarget
        ) { action in
            Button("Löschen", role: .destructive) {
                applyDelete(action)
                deleteTarget = nil
            }
            Button("Abbrechen", role: .cancel) {
                deleteTarget = nil
            }
        } message: { action in
            Text("\(action.targetTitle) wird dauerhaft entfernt.")
        }
        .id(store.revision)
        .onChange(of: store.lastError) { _, newValue in
            if let err = newValue {
                print("⚠️ Store-Fehler: \(err)")
            }
        }
    }
    
    private func renameSheetTitle(for action: EditAction) -> String {
        switch action {
        case .renameCourse: return "Kurs umbenennen"
        case .renameChapter: return "Kapitel umbenennen"
        case .renameSubchapter: return "Unterkapitel umbenennen"
        case .renamePart: return "Teil umbenennen"
        case .deleteCourse, .deleteChapter, .deleteSubchapter, .deletePart: return "Kurs löschen"
        case .deleteChaptersBulk(_):
            return "Kapitel löschen"
        case .groupChapters(_, _):
            return "Kapitel zu Teil zusammenfassen"
        }
    }

    private func applyRename(_ action: EditAction, newValue: String) {
        switch action {
        case .renameCourse(let c): store.renameCourse(c, to: newValue)
        case .renameChapter(let c): store.renameChapter(c, to: newValue)
        case .renameSubchapter(let s): store.renameSubchapter(s, to: newValue)
        case .renamePart(let p): store.renamePart(p, to: newValue)
        default: break
        }
    }

    private func applyDelete(_ action: EditAction) {
        switch action {
        case .deleteCourse(let c):     store.deleteCourse(c)
        case .deleteChapter(let c):    store.deleteChapter(c)
        case .deleteSubchapter(let s): store.deleteSubchapter(s)
        case .deletePart(let p):       store.deletePart(p)
        case .deleteChaptersBulk(let chapters):
            store.deleteChapters(chapters)
        default: break
        }
    }

    private func applyGroup(chapters: [Chapter], newTitle: String) {
        guard let courseID = store.selectedCourseID else { return }
        store.groupChapters(chapters, in: courseID, title: newTitle)
    }
}
