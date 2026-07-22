@extends('admin.layouts.admin')

@section('title', 'Kelola Booking')

@section('content')
<div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <div>
            <h1 class="text-xl font-bold text-gray-900">Kelola Transaksi Booking (MyTrip)</h1>
            <p class="text-sm text-gray-500 mt-1">List semua booking user pada aplikasi MyTrip. Ubah status booking langsung dari panel admin.</p>
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
                    <th class="px-6 py-4">Status</th>
                    <th class="px-6 py-4 text-center w-44">Aksi</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                @forelse($bookings as $index => $booking)
                <tr class="hover:bg-gray-50 transition">
                    <td class="px-6 py-4 text-center font-medium text-gray-900">{{ $bookings->firstItem() + $index }}</td>
                    <td class="px-6 py-4 font-semibold text-gray-900">{{ $booking->booking_code }}</td>
                    <td class="px-6 py-4 text-gray-600">{{ $booking->user->name ?? 'User Terhapus' }}</td>
                    <td class="px-6 py-4">
                        <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold uppercase tracking-wide {{ $booking->type == 'flight' ? 'bg-sky-100 text-sky-700' : ($booking->type == 'hotel' ? 'bg-amber-100 text-amber-700' : ($booking->type == 'train' ? 'bg-violet-100 text-violet-700' : 'bg-gray-100 text-gray-700')) }}">
                            {{ strtoupper($booking->type) }}
                        </span>
                    </td>
                    <td class="px-6 py-4 text-gray-600">#{{ $booking->item_id }}</td>
                    <td class="px-6 py-4 text-blue-600 font-medium">Rp {{ number_format($booking->total_price, 0, ',', '.') }}</td>
                    <td class="px-6 py-4">
                        @if($booking->status == 'pending')
                            <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-yellow-100 text-yellow-800 text-xs font-semibold">Pending</span>
                        @elseif($booking->status == 'paid')
                            <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-emerald-100 text-emerald-800 text-xs font-semibold">Paid</span>
                        @elseif($booking->status == 'cancel')
                            <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-rose-100 text-rose-800 text-xs font-semibold">Cancelled</span>
                        @else
                            <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-gray-100 text-gray-800 text-xs font-semibold">{{ ucfirst($booking->status) }}</span>
                        @endif
                    </td>
                    <td class="px-6 py-4 text-center">
                        <form action="{{ route('admin.booking.updateStatus', $booking->id) }}" method="POST" class="inline-flex items-center justify-center">
                            @csrf
                            @method('PATCH')
                            <select name="status" onchange="this.form.submit()" class="block w-full rounded-md border border-gray-200 bg-white py-2 px-3 text-sm text-gray-700 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-100">
                                <option value="pending" {{ $booking->status == 'pending' ? 'selected' : '' }}>Pending</option>
                                <option value="paid" {{ $booking->status == 'paid' ? 'selected' : '' }}>Paid</option>
                                <option value="cancel" {{ $booking->status == 'cancel' ? 'selected' : '' }}>Cancelled</option>
                            </select>
                        </form>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="8" class="px-6 py-10 text-center text-gray-400">Belum ada transaksi booking masuk dari Flutter.</td>
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