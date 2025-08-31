//
//  ProfileView.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 19/08/25.
//
import SwiftUI
import PhotosUI

struct ProfileView: View {
    @AppStorage("displayName") private var displayName: String = ""
    @AppStorage("profileImagePath") private var profileImagePath: String = ""

    @State private var selectedImage: UIImage? = nil
    @State private var showPhotoPicker = false
    @State private var photoSelection: PhotosPickerItem? = nil
    @FocusState private var isNameFieldFocused: Bool

    var body: some View {
        profile_view()
            .padding()
            .photosPicker(isPresented: $showPhotoPicker, selection: $photoSelection, matching: .images)
            .onChange(of: photoSelection) { oldItem, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                        saveProfileImage(uiImage)   // save permanently
                    }
                }
            }
            .onAppear {
                if selectedImage == nil, !profileImagePath.isEmpty {
                    selectedImage = loadProfileImage()
                }
            }
    }

    func profile_view() -> some View {
        HStack(spacing: 16) {
            ZStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Text(initials(from: displayName))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.blue)
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 1))
            .onTapGesture {
                showPhotoPicker = true
            }

            VStack(alignment: .leading, spacing: 4) {
                TextField("Your Name", text: $displayName)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                    .focused($isNameFieldFocused)
                    .onSubmit {
                        isNameFieldFocused = false
                    }
                Text("Tap to edit your details")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .onTapGesture {
                        isNameFieldFocused = true
                    }
            }
        }
        .padding(.vertical, 8)
    }

    func initials(from name: String) -> String {
        let components = name.split(separator: " ")
        let initials = components.prefix(2).compactMap { $0.first }.map { String($0) }
        return initials.joined().uppercased()
    }

    // MARK: - Save & Load Image
    private func saveProfileImage(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            let filename = getDocumentsDirectory().appendingPathComponent("profile.jpg")
            try? data.write(to: filename)
            profileImagePath = filename.path
        }
    }

    private func loadProfileImage() -> UIImage? {
        let fileURL = URL(fileURLWithPath: profileImagePath)
        if let data = try? Data(contentsOf: fileURL) {
            return UIImage(data: data)
        }
        return nil
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
