{{-- resources/views/admin/booking/index.blade.php --}}
@extends('admin.layouts.admin')

@section('title', 'Kelola Booking')

@section('content')
<div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <div>
            <h1 class="text-xl font-bold text-gray-900">Kelola Transaksi Booking (MyTrip)</h1>
            <p class="text-sm text-gray-500 mt-1">List semua booking user pada aplikasi MyTrip. Klik kode booking untuk melihat detail.</p>
        </div>
        <div class="flex gap-2">
            <span class="inline-flex items-center px-3 py-1 rounded-full bg-yellow-100 text-yellow-800 text-xs font-semibold">
                ⏳ {{ $bookings->where('status', 'pending')->count() }} Pending
            </span>
            <span class="inline-flex items-center px-3 py-1 rounded-full bg-emerald-100 text-emerald-800 text-xs font-semibold">
                ✅ {{ $bookings->where('status', 'paid')->count() }} Paid
            </span>
            <span class="inline-flex items-center px-3 py-1 rounded-full bg-rose-100 text-rose-800 text-xs font-semibold">
                ❌ {{ $bookings->where('status', 'cancel')->count() }} Cancel
            </span>
        </div>
    </div>

    @if(session('success'))
        <div class="mb-6 p-4 bg-emerald-50 border border-emerald-200 text-emerald-800 rounded-lg text-sm">
            {{ session('success') }}
        </div>
    @endif

    @if(session('error'))
        <div class="mb-6 p-4 bg-red-50 border border-red-200 text-red-800 rounded-lg text-sm">
            {{ session('error') }}
        </div>
    @endif

    <div class="overflow-x-auto rounded-lg border border-gray-200">
        <table class="w-full text-left border-collapse bg-white text-sm text-gray-500">
            <thead class="bg-gray-50 text-xs font-semibold uppercase text-gray-700 border-b border-gray-200">
                <tr>
                    <th class="px-6 py-4 text-center w-16">No</th>
                    <th class="px-6 py-4">Kode Booking</th>
                    <th class="px-6 py-4">Nama User</th>
                    <th class="px-6 py-4">Kategori</th>
                    <th class="px-6 py-4">Item ID</th>
                    <th class="px-6 py-4">Total Harga</th>
                    <th class="px-6 py-4">Status Booking</th>
                    <th class="px-6 py-4">Status Payment</th>
                    <th class="px-6 py-4">Promo</th>
                    <th class="px-6 py-4 text-center w-32">Aksi</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                @forelse($bookings as $index => $booking)
                <tr class="hover:bg-gray-50 transition">
                    <td class="px-6 py-4 text-center font-medium text-gray-900">{{ $bookings->firstItem() + $index }}</td>
                    <td class="px-6 py-4">
                        <a href="{{ route('admin.booking.show', $booking->id) }}" class="font-semibold text-blue-600 hover:text-blue-800 hover:underline">
                            {{ $booking->booking_code }}
                        </a>
                    </td>
                    <td class="px-6 py-4 text-gray-600">{{ $booking->user->name ?? 'User Terhapus' }}</td>
                    <td class="px-6 py-4">
                        <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold uppercase tracking-wide 
                            {{ $booking->type == 'bus' ? 'bg-sky-100 text-sky-700' : 
                               ($booking->type == 'hotel' ? 'bg-amber-100 text-amber-700' : 
                               ($booking->type == 'train' ? 'bg-violet-100 text-violet-700' : 'bg-gray-100 text-gray-700')) }}">
                            {{ strtoupper($booking->type) }}
                        </span>
                    </td>
                    <td class="px-6 py-4 text-gray-600">#{{ $booking->item_id }}</td>
                    <td class="px-6 py-4 text-blue-600 font-medium">Rp {{ number_format($booking->total_price, 0, ',', '.') }}</td>
                    <td class="px-6 py-4">
                        @include('admin.booking.partials.status-badge', ['status' => $booking->status])
                    </td>
                    <td class="px-6 py-4">
                        @if($booking->payment)
                            @include('admin.booking.partials.payment-status-badge', ['status' => $booking->payment->status])
                        @else
                            <span class="text-xs text-gray-400">-</span>
                        @endif
                    </td>
                    {{-- Di dalam tbody --}}
                    <td class="px-6 py-4">
                        @if($booking->promo)
                            <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-purple-100 text-purple-700 text-xs font-semibold">
                                {{ $booking->promo->code }}
                            </span>
                        @else
                            <span class="text-xs text-gray-400">-</span>
                        @endif
                    <td class="px-6 py-4 text-center">
                        <a href="{{ route('admin.booking.show', $booking->id) }}" class="inline-flex items-center px-3 py-1.5 bg-blue-50 text-blue-600 hover:bg-blue-100 rounded-lg text-xs font-medium transition">
                            Detail
                        </a>
                    </td>
                    

                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="9" class="px-6 py-10 text-center text-gray-400">Belum ada transaksi booking masuk dari Flutter.</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="mt-6">
        {{ $bookings->links() }}
    </div>
</div>
@endsection