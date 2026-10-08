import SwiftUI

struct OrderDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: OrderDetailViewModel

    init(orderID: Int) {
        _viewModel = State(initialValue: OrderDetailViewModel(orderID: orderID))
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            if viewModel.isLoading && viewModel.order == nil {
                OrderDetailLoadingView()
            } else if let order = viewModel.order {
                content(order)
            } else if !viewModel.errorMessage.isEmpty {
                errorView
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task { viewModel.load() }
    }

    private var header: some View {
        HStack(spacing: 14) {
            Button { dismiss() } label: { Image(systemName: "arrow.left").font(.system(size: 22, weight: .medium)).foregroundStyle(AppColors.title) }
                .buttonStyle(.plain)
            Text(viewModel.order.map { "#\($0.orderNumber)" } ?? "Order Details")
                .montserrat(20, weight: .bold)
                .foregroundStyle(AppColors.title)
            Spacer()
            Image(systemName: "bell").font(.system(size: 19)).foregroundStyle(AppColors.subtitle)
        }
        .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 22)
    }

    private func content(_ order: OrderDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                summaryCard(order)
                Text("Items (\(order.items.count))").montserrat(20, weight: .bold).foregroundStyle(AppColors.title)
                itemsSection(order.items)
                Text("Timeline").montserrat(20, weight: .bold).foregroundStyle(AppColors.title)
                timelineSection(order.timeline.steps)
                Button("Deposit Slip") { }
                    .montserrat(17, weight: .bold)
                    .foregroundStyle(order.depositSlip.canUpload ? AppColors.primary : AppColors.subtitle)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .overlay { RoundedRectangle(cornerRadius: 14).stroke(order.depositSlip.canUpload ? AppColors.primary : AppColors.border, lineWidth: 2) }
                    .buttonStyle(.plain)
                    .disabled(!order.depositSlip.canUpload)
            }
            .padding(.horizontal, 20).padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }

    private func summaryCard(_ order: OrderDetail) -> some View {
        VStack(spacing: 12) {
            summaryRow("Payment", order.paymentStatusLabel, emphasized: true, color: AppColors.primary)
            summaryRow("Tracking ID", order.trackingNumber ?? "Not available", emphasized: order.trackingNumber == nil, color: order.trackingNumber == nil ? AppColors.primary : AppColors.title)
            summaryRow("Total", "Rs \(order.totalPayable.orderDetailDisplayPrice)")
            summaryRow("Delivery", order.deliveryStatusLabel)
        }
        .padding(24).background(AppColors.surface).clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func summaryRow(_ title: String, _ value: String, emphasized: Bool = false, color: Color = AppColors.title) -> some View {
        HStack {
            Text(title).montserrat(17)
            Spacer()
            Text(value).montserrat(17, weight: emphasized ? .bold : .semibold).foregroundStyle(color)
        }
        .foregroundStyle(AppColors.title)
    }

    private func itemsSection(_ items: [OrderDetailItem]) -> some View {
        VStack(spacing: 15) {
            ForEach(items) { item in
                HStack(spacing: 12) {
                    AsyncImage(url: item.image.flatMap(URL.init)) { image in image.resizable().scaledToFit() } placeholder: { Image(systemName: "photo").foregroundStyle(AppColors.subtitle) }
                        .frame(width: 56, height: 40)
                    Text(item.title).montserrat(14).lineLimit(1)
                    Spacer()
                    Text("\(item.packQuantity) packs").montserrat(14, weight: .bold)
                }
            }
        }
    }

    private func timelineSection(_ steps: [OrderTimelineStep]) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(steps) { step in
                HStack(spacing: 14) {
                    Circle().fill(step.active ? AppColors.primary : (step.completed ? AppColors.primary.opacity(0.35) : AppColors.border)).frame(width: 16, height: 16)
                    Text(step.label).montserrat(16).foregroundStyle(step.active || step.completed ? AppColors.title : AppColors.subtitle)
                }
            }
        }
    }

    private var errorView: some View {
        VStack(spacing: 12) { Text(viewModel.errorMessage).montserrat(13).foregroundStyle(AppColors.subtitle); Button("Try Again") { viewModel.load() }.foregroundStyle(AppColors.primary) }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct OrderDetailLoadingView: View {
    var body: some View { VStack(spacing: 14) { SkeletonBlock(width: nil, height: 180, cornerRadius: 14); SkeletonBlock(width: nil, height: 220, cornerRadius: 14); SkeletonBlock(width: nil, height: 300, cornerRadius: 14) }.padding(20) }
}

private extension Double { var orderDetailDisplayPrice: String { formatted(.number.precision(.fractionLength(0...2))) } }

#Preview { OrderDetailView(orderID: 62) }
