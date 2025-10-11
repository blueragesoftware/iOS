import SwiftUI
import PhotosUI
import OSLog

struct AgentLoadedFilesSectionView: View {

    private struct FileCellView: View {

        private static let imageSize: CGFloat = 28

        private let file: Agent.File

        init(file: Agent.File) {
            self.file = file
        }

        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: self.systemImageName)
                    .foregroundStyle(.white)
                    .fixedSize()
                    .background {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(self.fillColor)
                            .frame(width: 28, height: 28)
                    }
                    .frame(width: 28, height: 28)

                Text(self.file.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)

                Spacer()
            }
        }

        private var systemImageName: String {
            switch self.file.type {
            case .image:
                "photo.fill"
            case .file:
                "document.fill"
            }
        }

        private var fillColor: Color {
            switch self.file.type {
            case .image:
                    .green
            case .file:
                    .blue
            }
        }

    }

    @State private var photosPickerItem: PhotosPickerItem?

    @State private var showsFilePicker = false

    @State private var showsPhotoPicker = false

    @Binding private var alertError: Error?

    @State var isUploading: Bool

    private let files: [Agent.File]

    private let onRemove: (IndexSet) -> Void

    private let onAdd: (AgentLoadedViewModel.LocalFile) -> Void

    init(files: [Agent.File],
         isUploading: Bool,
         onRemove: @escaping (IndexSet) -> Void,
         onAdd: @escaping (AgentLoadedViewModel.LocalFile) -> Void) {
        self.files = files
        self._alertError = .constant(nil)
        self._isUploading = .init(wrappedValue: isUploading)
        self.onRemove = onRemove
        self.onAdd = onAdd
    }

    var body: some View {
        Section {
            ForEach(self.files) { file in
                FileCellView(file: file)
            }
            .onDelete { offsets in
                self.onRemove(offsets)
            }

            if self.isUploading {
                ProgressView()
            } else {
                Menu {
                    Button(BluerageStrings.agentFileTypeImage, systemImage: "photo") {
                        self.showsPhotoPicker = true
                    }

                    Button(BluerageStrings.agentFileTypeFile, systemImage: "document") {
                        self.showsFilePicker = true
                    }
                } label: {
                    Text(BluerageStrings.agentNewFileButtonTitle)
                        .foregroundStyle(.link)
                }
            }
        } header: {
            Text(BluerageStrings.agentFilesSectionHeader)
        } footer: {
            Text(BluerageStrings.agentSectionFooter)
        }
        .background(EmptyView().photosPicker(isPresented: self.$showsPhotoPicker,
                                             selection: self.$photosPickerItem,
                                             matching: .images))
        .background(EmptyView().fileImporter(isPresented: self.$showsFilePicker,
                                             allowedContentTypes: [.pdf]) { result in
                                   switch result {
                                   case .success(let fileUrl):
                                       self.onAdd(.file(id: UUID().uuidString, url: fileUrl))
                                   case .failure(let error):
                                       Logger.agents.error("Error importing file: \(error.localizedDescription, privacy: .public)")

                                       self.alertError = error
                                   }
                               })
        .background(EmptyView().errorAlert(error: self.$alertError))
        .onChange(of: self.photosPickerItem) { _, newValue in
            guard let newValue else {
                return
            }

            Task {
                do {
                    guard let data = try await newValue.loadTransferable(type: Data.self) else {
                        return
                    }

                    self.onAdd(.image(id: UUID().uuidString,
                                      name: newValue.itemIdentifier ?? "image-\(UUID().uuidString.prefix(4))",
                                      data: data,
                                      uTType: newValue.supportedContentTypes.first))
                } catch {
                    Logger.agents.error("Error loading image file: \(error.localizedDescription, privacy: .public)")

                    self.alertError = error
                }
            }
        }
    }

}
