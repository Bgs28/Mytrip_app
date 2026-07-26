@extends('admin.layouts.admin')

@section('title', 'Detail Kamar - ' . $room->room_number)

@section('content')
<div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <div class="flex items-center gap-4 mb-6">
        <a href="{{ route('admin.rooms.index', ['hotel_id' => $room->hotel_id]) }}" class="text-blue-600 hover:text-blue-800">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path>
            </svg>
        </a>
        <h1 class="text-xl font-bold text-gray-900">🛏️ Detail Kamar - {{ $room->room_number }}</h1>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Main Info -->
        <div class="lg:col-span-2 space-y-6">
            <!-- Hotel Info -->
            <div class="bg-gray-50 rounded-lg p-6 border border-gray-200">
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <p class="text-sm text-gray-500">Hotel</p>
                        <p class="text-lg font-semibold">{{ $room->hotel->name ?? '-' }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Lokasi</p>
                        <p class="text-lg">{{ $room->hotel->location ?? '-' }}</p>
                    </div>
                </div>
            </div>

            <!-- Room Details -->
            <div class="bg-white rounded-lg border border-gray-200 p-6">
                <h3 class="font-semibold text-gray-900 mb-4">📋 Detail Kamar</h3>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <p class="text-sm text-gray-500">Nomor Kamar</p>
                        <p class="text-2xl font-bold text-blue-600">{{ $room->room_number }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Nama Kamar</p>
                        <p class="text-lg font-semibold">{{ $room->room_name }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Tipe Kamar</p>
                        <p>
                            <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold
                                {{ $room->room_type == 'standard' ? 'bg-gray-100 text-gray-700' : 
                                   ($room->room_type == 'deluxe' ? 'bg-blue-100 text-blue-700' : 
                                   ($room->room_type == 'suite' ? 'bg-purple-100 text-purple-700' : 
                                   ($room->room_type == 'family' ? 'bg-green-100 text-green-700' : 
                                   'bg-amber-100 text-amber-700'))) }}">
                                {{ $room->room_type_label }}
                            </span>
                        </p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Harga per Malam</p>
                        <p class="text-xl font-bold text-emerald-600">Rp {{ number_format($room->price_per_night, 0, ',', '.') }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Kapasitas</p>
                        <p class="font-semibold">{{ $room->capacity }} orang</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Tipe Tempat Tidur</p>
                        <p class="font-semibold">{{ $room->bed_type_label }}</p>
                    </div>
                    @if($room->size)
                        <div>
                            <p class="text-sm text-gray-500">Ukuran Kamar</p>
                            <p class="font-semibold">{{ $room->size }} m²</p>
                        </div>
                    @endif
                    <div>
                        <p class="text-sm text-gray-500">Status</p>
                        @if($room->is_available)
                            <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-emerald-100 text-emerald-800 text-xs font-semibold">
                                ✅ Tersedia
                            </span>
                        @else
                            <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-red-100 text-red-800 text-xs font-semibold">
                                ❌ Tidak Tersedia
                            </span>
                        @endif
                    </div>
                </div>
            </div>

            <!-- Gambar Kamar -->
            <div class="bg-white rounded-lg border border-gray-200 p-6">
                <h3 class="font-semibold text-gray-900 mb-4">🖼️ Galeri Kamar</h3>
                
                @if($room->thumbnail)
                    <div class="mb-4">
                        <p class="text-sm text-gray-500 mb-2">Thumbnail</p>
                        <img src="{{ asset('storage/rooms/' . $room->thumbnail) }}" 
                            alt="{{ $room->room_name }}" 
                            class="w-48 h-48 object-cover rounded-lg border border-gray-200">
                    </div>
                @endif

                @if($room->images && count($room->images) > 0)
                    <div>
                        <p class="text-sm text-gray-500 mb-2">Gambar Lainnya</p>
                        <div class="flex flex-wrap gap-2">
                            @foreach($room->images as $image)
                                <img src="{{ asset('storage/rooms/' . $image) }}" 
                                    alt="{{ $room->room_name }}" 
                                    class="w-32 h-32 object-cover rounded-lg border border-gray-200 hover:opacity-80 transition cursor-pointer"
                                    onclick="window.open(this.src, '_blank')">
                            @endforeach
                        </div>
                    </div>
                @endif

                @if(!$room->thumbnail && (!$room->images || count($room->images) == 0))
                    <p class="text-sm text-gray-400">Belum ada gambar untuk kamar ini.</p>
                @endif
            </div>

            <!-- Description -->
            @if($room->description)
                <div class="bg-white rounded-lg border border-gray-200 p-6">
                    <h3 class="font-semibold text-gray-900 mb-2">📝 Deskripsi</h3>
                    <p class="text-sm">{{ $room->description }}</p>
                </div>
            @endif

            <!-- Facilities -->
            @if($room->facilities && count($room->facilities) > 0)
                <div class="bg-white rounded-lg border border-gray-200 p-6">
                    <h3 class="font-semibold text-gray-900 mb-2">🎯 Fasilitas</h3>
                    <div class="flex flex-wrap gap-2">
                        @foreach($room->facilities as $facility)
                            <span class="inline-flex items-center px-3 py-1 rounded-full bg-blue-50 text-blue-700 text-xs font-medium">
                                {{ $facility }}
                            </span>
                        @endforeach
                    </div>
                </div>
            @endif

            <!-- Booking History -->
            @if($room->roomBookings->count() > 0)
                <div class="bg-white rounded-lg border border-gray-200 p-6">
                    <h3 class="font-semibold text-gray-900 mb-4">📋 Riwayat Booking Kamar</h3>
                    <div class="space-y-2">
                        @foreach($room->roomBookings->take(5) as $booking)
                            <div class="flex justify-between items-center p-2 bg-gray-50 rounded">
                                <div>
                                    <span class="text-sm font-medium">{{ $booking->booking->booking_code ?? 'N/A' }}</span>
                                    <span class="text-xs text-gray-500 ml-2">
                                        {{ $booking->check_in_date->format('d/m/Y') }} - {{ $booking->check_out_date->format('d/m/Y') }}
                                    </span>
                                </div>
                                <span class="text-xs {{ $booking->status == 'confirmed' ? 'text-emerald-600' : 'text-gray-500' }}">
                                    {{ $booking->status_label }}
                                </span>
                            </div>
                        @endforeach
                        @if($room->roomBookings->count() > 5)
                            <p class="text-sm text-gray-400">... dan {{ $room->roomBookings->count() - 5 }} booking lainnya</p>
                        @endif
                    </div>
                </div>
            @endif
        </div>

        <!-- Sidebar -->
        <div class="lg:col-span-1 space-y-6">
            <div class="bg-gray-50 rounded-lg border border-gray-200 p-6">
                <h3 class="font-semibold text-gray-900 mb-4">⚙️ Aksi</h3>
                <div class="space-y-3">
                    <a href="{{ route('admin.rooms.edit', $room->id) }}" 
                       class="block w-full bg-amber-600 hover:bg-amber-700 text-white text-center font-medium py-2 rounded-lg transition">
                        ✏️ Edit Kamar
                    </a>
                    <form action="{{ route('admin.rooms.toggleAvailability', $room->id) }}" method="POST">
                        @csrf
                        <button type="submit" 
                                class="block w-full {{ $room->is_available ? 'bg-red-600 hover:bg-red-700' : 'bg-emerald-600 hover:bg-emerald-700' }} text-white font-medium py-2 rounded-lg transition">
                            {{ $room->is_available ? '❌ Non-Aktifkan' : '✅ Aktifkan' }}
                        </button>
                    </form>
                    <form action="{{ route('admin.rooms.destroy', $room->id) }}" method="POST" 
                          onsubmit="return confirm('Apakah Anda yakin ingin menghapus kamar ini?')">
                        @csrf
                        @method('DELETE')
                        <button type="submit" class="block w-full bg-red-600 hover:bg-red-700 text-white font-medium py-2 rounded-lg transition">
                            🗑️ Hapus Kamar
                        </button>
                    </form>
                </div>
            </div>

            <div class="bg-white rounded-lg border border-gray-200 p-6">
                <h3 class="font-semibold text-gray-900 mb-4">📌 Informasi</h3>
                <div class="space-y-2 text-sm">
                    <div class="flex justify-between">
                        <span class="text-gray-500">Dibuat</span>
                        <span>{{ $room->created_at->format('d M Y H:i') }}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-gray-500">Diperbarui</span>
                        <span>{{ $room->updated_at->format('d M Y H:i') }}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-gray-500">Total Booking</span>
                        <span>{{ $room->roomBookings->count() }}</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection