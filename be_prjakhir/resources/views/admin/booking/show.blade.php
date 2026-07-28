{{-- resources/views/admin/booking/show.blade.php --}}
@extends('admin.layouts.admin')

@section('title', 'Detail Booking - ' . $booking->booking_code)

@section('content')
<div class="space-y-6">
    <!-- Tombol Kembali -->
    <div>
        <a href="{{ route('admin.booking.index') }}" class="inline-flex items-center text-blue-600 hover:text-blue-800">
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path>
            </svg>
            Kembali ke Daftar Booking
        </a>
    </div>

    <!-- Header -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
            <div>
                <h1 class="text-2xl font-bold text-gray-900">Detail Booking</h1>
                <p class="text-sm text-gray-500 mt-1">Kode Booking: <span class="font-semibold text-gray-700">{{ $booking->booking_code }}</span></p>
            </div>
            <div class="flex items-center gap-2">
                <span class="text-sm text-gray-500">Status:</span>
                @include('admin.booking.partials.status-badge', ['status' => $booking->status])
            </div>
        </div>
    </div>

    <!-- Alert Messages -->
    @if(session('success'))
        <div class="p-4 bg-emerald-50 border border-emerald-200 text-emerald-800 rounded-lg text-sm">
            {{ session('success') }}
        </div>
    @endif

    @if(session('error'))
        <div class="p-4 bg-red-50 border border-red-200 text-red-800 rounded-lg text-sm">
            {{ session('error') }}
        </div>
    @endif

    <!-- Grid Info -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Informasi Booking -->
        <div class="lg:col-span-2 space-y-6">
            <!-- Informasi User -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
                <h2 class="text-lg font-semibold text-gray-900 mb-4">👤 Informasi Pemesan</h2>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <p class="text-sm text-gray-500">Nama</p>
                        <p class="font-medium">{{ $booking->user->name ?? 'User Terhapus' }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Email</p>
                        <p class="font-medium">{{ $booking->user->email ?? '-' }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Tanggal Booking</p>
                        <p class="font-medium">{{ $booking->created_at->format('d M Y H:i') }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">ID User</p>
                        <p class="font-medium">#{{ $booking->user_id }}</p>
                    </div>
                </div>
            </div>

            <!-- Informasi Item -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
                <h2 class="text-lg font-semibold text-gray-900 mb-4">📋 Detail Item</h2>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <p class="text-sm text-gray-500">Kategori</p>
                        <p>
                            <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold uppercase tracking-wide
                                {{ $booking->type == 'bus' ? 'bg-sky-100 text-sky-700' : 
                                   ($booking->type == 'hotel' ? 'bg-amber-100 text-amber-700' : 
                                   ($booking->type == 'train' ? 'bg-violet-100 text-violet-700' : 'bg-gray-100 text-gray-700')) }}">
                                {{ strtoupper($booking->type) }}
                            </span>
                        </p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Item ID</p>
                        <p class="font-medium">#{{ $booking->item_id }}</p>
                    </div>
                </div>
            </div>

            <!-- Informasi Pembayaran -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
                <h2 class="text-lg font-semibold text-gray-900 mb-4">💳 Informasi Pembayaran</h2>
                
                @if($booking->payment)
                    <div class="space-y-3">
                        <div class="grid grid-cols-2 gap-4">
                            <div>
                                <p class="text-sm text-gray-500">Invoice Number</p>
                                <p class="font-medium">{{ $booking->payment->invoice_number ?? '-' }}</p>
                            </div>
                            <div>
                                <p class="text-sm text-gray-500">Metode Pembayaran</p>
                                <p class="font-medium">{{ $booking->payment->payment_method_label ?? '-' }}</p>
                            </div>
                            <div>
                                <p class="text-sm text-gray-500">Total Harga</p>
                                <p class="font-semibold text-blue-600 text-lg">Rp {{ number_format($booking->total_price, 0, ',', '.') }}</p>
                            </div>
                            <div>
                                <p class="text-sm text-gray-500">Status Pembayaran</p>
                                <div>
                                    @include('admin.booking.partials.payment-status-badge', ['status' => $booking->payment->status])
                                </div>
                            </div>
                        </div>

                        @if($booking->payment->discount_amount > 0)
                            <div class="p-3 bg-emerald-50 rounded-lg border border-emerald-200">
                                <p class="text-sm text-emerald-700">
                                    🎫 Diskon: Rp {{ number_format($booking->payment->discount_amount, 0, ',', '.') }}
                                </p>
                                @if($booking->payment->promo)
                                    <p class="text-xs text-emerald-600">Kode Promo: {{ $booking->payment->promo->code }}</p>
                                @endif
                            </div>
                        @endif

                        @if($booking->payment->notes)
                            <div class="p-3 bg-gray-50 rounded-lg border border-gray-200">
                                <p class="text-sm text-gray-500">Catatan:</p>
                                <p class="text-sm">{{ $booking->payment->notes }}</p>
                            </div>
                        @endif

                        @if($booking->payment->proof_of_payment)
                            <div class="mt-4">
                                <p class="text-sm text-gray-500 mb-2">Bukti Pembayaran:</p>
                                <div class="border rounded-lg overflow-hidden max-w-md">
                                    <img src="{{ $booking->payment->proof_url }}" 
                                         alt="Bukti Pembayaran"
                                         class="w-full cursor-pointer hover:opacity-90 transition"
                                         onclick="window.open(this.src, '_blank')"
                                         onerror="this.parentElement.innerHTML='<p class=\'text-red-500 text-sm p-3\'>⚠️ Gambar tidak dapat dimuat: {{ $booking->payment->proof_url }}</p>'">
                                </div>
                            </div>
                        @else
                            <div class="mt-4 p-3 bg-yellow-50 rounded-lg border border-yellow-200">
                                <p class="text-sm text-yellow-700">⏳ Belum ada bukti pembayaran yang diunggah.</p>
                            </div>
                        @endif
                    </div>
                @else
                    <div class="p-4 bg-gray-50 rounded-lg border border-gray-200 text-center">
                        <p class="text-gray-500">Belum ada data pembayaran untuk booking ini.</p>
                    </div>
                @endif
            </div>

            {{-- Tambahkan setelah Informasi Pembayaran --}}

            <!-- Informasi Promo -->
            @if($booking->promo)
                <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
                    <h2 class="text-lg font-semibold text-gray-900 mb-4">🎫 Informasi Promo</h2>
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <p class="text-sm text-gray-500">Kode Promo</p>
                            <p class="font-mono font-semibold text-blue-600">{{ $booking->promo->code }}</p>
                        </div>
                        <div>
                            <p class="text-sm text-gray-500">Nama Promo</p>
                            <p class="font-medium">{{ $booking->promo->name }}</p>
                        </div>
                        <div>
                            <p class="text-sm text-gray-500">Diskon</p>
                            <p class="font-medium text-emerald-600">
                                @if($booking->promo->discount_type == 'percentage')
                                    {{ $booking->promo->discount_value }}%
                                @else
                                    Rp {{ number_format($booking->promo->discount_value, 0, ',', '.') }}
                                @endif
                            </p>
                        </div>
                        <div>
                            <p class="text-sm text-gray-500">Total Diskon</p>
                            <p class="font-medium text-emerald-600">Rp {{ number_format($booking->discount_amount, 0, ',', '.') }}</p>
                        </div>
                    </div>
                </div>
            @endif

            <!-- E-Ticket Section -->
            @if($booking->status == 'paid')
                <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
                    <h2 class="text-lg font-semibold text-gray-900 mb-4">🎫 E-Ticket</h2>
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <p class="text-sm text-gray-500">Kode Tiket</p>
                            <p class="font-semibold text-lg">{{ $booking->eTicket->ticket_code ?? '-' }}</p>
                        </div>
                        <div>
                            <p class="text-sm text-gray-500">Kode Check-in</p>
                            <p class="font-semibold text-lg font-mono">{{ $booking->eTicket->check_in_code ?? '-' }}</p>
                        </div>
                        <div>
                            <p class="text-sm text-gray-500">Valid Until</p>
                            <p class="font-medium">{{ isset($booking->eTicket) ? $booking->eTicket->valid_until->format('d M Y') : '-' }}</p>
                        </div>
                        <div>
                            <p class="text-sm text-gray-500">Status</p>
                            <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold 
                                {{ $booking->eTicket && $booking->eTicket->is_used ? 'bg-gray-100 text-gray-800' : 'bg-emerald-100 text-emerald-800' }}">
                                {{ $booking->eTicket && $booking->eTicket->is_used ? 'Used' : 'Active' }}
                            </span>
                        </div>
                    </div>
                    @if($booking->eTicket && $booking->eTicket->qr_code)
                        <div class="mt-4 p-4 bg-gray-50 rounded-lg border border-gray-200 text-center">
                            <p class="text-sm text-gray-500 mb-2">QR Code</p>
                            <img src="data:image/png;base64,{{ $booking->eTicket->qr_code }}" 
                                alt="QR Code" 
                                class="mx-auto w-48 h-48">
                        </div>
                    @endif
                </div>
            @endif
        </div>

        <!-- Sidebar - Aksi -->
        <div class="lg:col-span-1 space-y-6">
            <!-- Update Status -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
                <h2 class="text-lg font-semibold text-gray-900 mb-4">⚙️ Ubah Status</h2>
                <form action="{{ route('admin.booking.updateStatus', $booking->id) }}" method="POST">
                    @csrf
                    @method('PATCH')
                    <div class="space-y-3">
                        <select name="status" class="w-full rounded-md border border-gray-300 bg-white py-2 px-3 text-sm text-gray-700 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-100">
                            <option value="pending" {{ $booking->status == 'pending' ? 'selected' : '' }}>Pending</option>
                            <option value="paid" {{ $booking->status == 'paid' ? 'selected' : '' }}>Paid</option>
                            <option value="cancel" {{ $booking->status == 'cancel' ? 'selected' : '' }}>Cancelled</option>
                        </select>
                        <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded-lg transition text-sm">
                            Update Status
                        </button>
                    </div>
                </form>
            </div>

            <!-- Approve/Reject Payment -->
            @if($booking->payment && $booking->payment->status == 'pending' && $booking->payment->proof_of_payment)
                <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
                    <h2 class="text-lg font-semibold text-gray-900 mb-4">✅ Verifikasi Pembayaran</h2>
                    <div class="space-y-3">
                        <p class="text-sm text-gray-500">User telah mengupload bukti pembayaran. Silahkan verifikasi.</p>
                        <div class="grid grid-cols-2 gap-2">
                            <form action="{{ route('admin.booking.approvePayment', $booking->id) }}" method="POST">
                                @csrf
                                <button type="submit" class="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-semibold py-2 px-4 rounded-lg transition text-sm">
                                    ✅ Approve
                                </button>
                            </form>
                            <form action="{{ route('admin.booking.rejectPayment', $booking->id) }}" method="POST">
                                @csrf
                                <button type="submit" class="w-full bg-red-600 hover:bg-red-700 text-white font-semibold py-2 px-4 rounded-lg transition text-sm">
                                    ❌ Reject
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            @endif

            <!-- Info Tambahan -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
                <h2 class="text-lg font-semibold text-gray-900 mb-4">📊 Informasi Tambahan</h2>
                <div class="space-y-2 text-sm">
                    <div class="flex justify-between">
                        <span class="text-gray-500">Dibuat</span>
                        <span>{{ $booking->created_at->format('d M Y H:i') }}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-gray-500">Terakhir Update</span>
                        <span>{{ $booking->updated_at->format('d M Y H:i') }}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-gray-500">ID Booking</span>
                        <span>#{{ $booking->id }}</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection