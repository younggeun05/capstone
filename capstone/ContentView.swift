//
//  ContentView.swift
//  capstone
//
//  Created by 박영근 on 4/16/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [ScanItem] // -> ScanItem 사용
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        detailView(for: item)
                    } label: {
                        listRow(for: item)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("스캔 목록")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("새 스캔 추가", systemImage:"plus")
                    }
                }
            }
        } detail: {
            Text("스캔 항목을 선택하시오")
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - ViewBuilder 분리
    
    @ViewBuilder
    func listRow(for item: ScanItem) -> some View {
        HStack {
            if let thumbPath = item.thumbnailPath,
               let image = UIImage(contentsOfFile: thumbPath) {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 44, height: 44)
                    .cornerRadius(8)
            }
            VStack(alignment: .leading) {
                Text(item.fileName)
                Text(item.timestamp, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    @ViewBuilder
    func detailView(for item: ScanItem) -> some View {
        VStack {
            Text("파일명: \(item.fileName)")
            Text("스캔 시각: \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
            if let thumbPath = item.thumbnailPath,
               let image = UIImage(contentsOfFile: thumbPath) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(12)
                    .padding()
            }
            
            if let modelURL = item.modelFileURL {
                Text("모델 경로: \(modelURL.lastPathComponent)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    // MARK: - 추가 / 삭제
    
    private func addItem() {
        withAnimation {
            let filename = "Scan_\(UUID().uuidString.prefix(5)).usdz"
            let newItem = ScanItem(fileName: filename)
            modelContext.insert(newItem)
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
        
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ScanItem.self, inMemory: true)
}
