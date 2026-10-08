import SwiftUI

struct OrdersView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = OrdersViewModel()
    @State private var selectedFilter = "All"
    @State private var selectedOrderID: Int?

    private let filters = [
        "All", "Pending", "Payment Received", "Process", "Ready For Dispatch",
        "Shipped", "Delivered", "Completed", "Cancelled", "On Hold"
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
            filterBar
            if viewModel.isLoading && viewModel.orders.isEmpty {
                OrdersLoadingView()
            } else if !viewModel.errorMessage.isEmpty {
                errorView
            } else {
                orderList
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $selectedOrderID) { orderID in
            OrderDetailView(orderID: orderID)
        }
        .task { viewModel.load() }
    }

    private var header: some View {
        HStack(spacing: 14) {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(AppColors.title)
            }
            .buttonStyle(.plain)
            Text("My Orders").montserrat(20, weight: .bold).foregroundStyle(AppColors.title)
            Spacer()
            Image(systemName: "bell").font(.system(size: 19)).foregroundStyle(AppColors.subtitle)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 20)
    }

    private var filterBar: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(filters, id: \.self) { filter in
                    Button {
                        selectedFilter = filter
                        viewModel.load(status: apiStatus(for: filter))
                    } label: {
                        Text("\(filter) \(count(for: filter))")
                            .montserrat(12, weight: selectedFilter == filter ? .semibold : .regular)
                            .foregroundStyle(selectedFilter == filter ? .white : AppColors.title)
                            .padding(.horizontal, 15)
                            .frame(height: 30)
                            .background(selectedFilter == filter ? AppColors.primary : AppColors.surface)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
        .padding(.bottom, 16)
    }

    private var orderList: some View {
        return ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.orders) { order in
                    Button { selectedOrderID = order.id } label: {
                        orderRow(order)
                    }
                    .buttonStyle(.plain)
                        .onAppear { viewModel.loadMoreIfNeeded(after: order) }
                }
                if viewModel.isLoadingMore {
                    ProgressView().tint(AppColors.primary).padding(.vertical, 12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
    }

    private func orderRow(_ order: OrderSummary) -> some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text("#\(order.orderNumber.replacingOccurrences(of: "ORD-", with: "ORD-"))")
                    .montserrat(15, weight: .bold)
                    .foregroundStyle(AppColors.title)
                Text("\(order.totalProducts) items · Rs \(order.totalPayable.ordersDisplayPrice)")
                    .montserrat(12)
                    .foregroundStyle(AppColors.subtitle)
            }
            Spacer()
            HStack(spacing: 6) {
                Circle().fill(statusColor(order)).frame(width: 8, height: 8)
                Text(displayStatus(for: order))
                    .montserrat(12)
                    .foregroundStyle(AppColors.title)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AppColors.subtitle)
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 62)
        .background(AppColors.background)
        .overlay { RoundedRectangle(cornerRadius: 13).stroke(AppColors.border, lineWidth: 1) }
        .clipShape(RoundedRectangle(cornerRadius: 13))
    }

    private func normalizedStatus(_ order: OrderSummary) -> String {
        let label = order.statusLabel.lowercased()
        if label.contains("pending") || label.contains("reserved") { return "pending" }
        if label.contains("payment") { return "payment received" }
        if label.contains("process") { return "process" }
        if label.contains("ready") { return "ready for dispatch" }
        if label.contains("ship") { return "shipped" }
        if label.contains("deliver") { return "delivered" }
        if label.contains("complete") { return "completed" }
        if label.contains("cancel") { return "cancelled" }
        if label.contains("hold") { return "on hold" }
        return label
    }

    private func count(for filter: String) -> Int {
        guard let counts = viewModel.counts else { return 0 }
        switch filter {
        case "All": return counts.all
        case "Pending": return counts.reserved
        case "Payment Received": return counts.paymentReceived
        case "Process": return counts.inProcess
        case "Ready For Dispatch": return counts.readyForDispatch
        case "Shipped": return counts.shipped
        case "Delivered": return counts.delivered
        case "Completed": return counts.completed
        case "Cancelled": return counts.cancelled
        case "On Hold": return counts.onHold
        default: return 0
        }
    }

    private func apiStatus(for filter: String) -> String {
        switch filter {
        case "Pending": return "reserved"
        case "Payment Received": return "payment_received"
        case "Process": return "in_process"
        case "Ready For Dispatch": return "ready_for_dispatch"
        case "Shipped": return "shipped"
        case "Delivered": return "delivered"
        case "Completed": return "completed"
        case "Cancelled": return "cancelled"
        case "On Hold": return "on_hold"
        default: return "all"
        }
    }

    private func displayStatus(for order: OrderSummary) -> String {
        normalizedStatus(order) == "pending" ? "Pending" : order.statusLabel
    }

    private func statusColor(_ order: OrderSummary) -> Color {
        switch normalizedStatus(order) {
        case "shipped": return .blue
        case "delivered": return .green
        default: return .orange
        }
    }

    private var errorView: some View {
        VStack(spacing: 12) {
            Text(viewModel.errorMessage).montserrat(13).foregroundStyle(AppColors.subtitle)
            Button("Try Again") { viewModel.load() }.foregroundStyle(AppColors.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct OrdersLoadingView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(0..<5, id: \.self) { _ in SkeletonBlock(width: nil, height: 62, cornerRadius: 13) }
            }
            .padding(20)
        }
    }
}

private extension Double {
    var ordersDisplayPrice: String { formatted(.number.precision(.fractionLength(0...2))) }
}

#Preview { OrdersView() }
