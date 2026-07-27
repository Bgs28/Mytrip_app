@extends('admin.layouts.admin')

@section('title', 'Detail Hotel - ' . $hotel->name)

@section('content')
<div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <div class="flex items-center gap-4 mb-6">
        <a href="{{ route('admin.hotels.index') }}" class="text-blue-600 hover:text-blue-800">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path>
            </svg>
        </a>
        <h1 class="text-xl font-bold text-gray-900">🏨 Detail Hotel - {{ $hotel->name }}</h1>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Main Info -->
        <div class="lg:col-span-2 space-y-6">
            <!-- Hotel Info -->
            <div class="bg-gray-50 rounded-lg p-6 border border-gray-200">
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <p class="text-sm text-gray-500">Nama Hotel</p>
                        <p class="text-lg font-semibold">{{ $hotel->name }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Lokasi</p>
                        <p class="text-lg font-semibold">{{ $hotel->location }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Rating</p>
                        <div class="flex items-center gap-2">
                            <div class="flex items-center gap-0.5">
                                @php
                                    $stars = $hotel->stars;
                                @endphp
                                @for($i = 0; $i < $stars['full']; $i++)
                                    <svg class="w-5 h-5 text-yellow-400 fill-current" viewBox="0 0 20 20">
                                        <path d="M10 15l-5.878 3.09 1.123-6.545L.489 6.91l6.572-.955L10 0l2.939 5.955 6.572.955-4.756 4.635 1.123 6.545z"/>
                                    </svg>
                                @endfor
                                @if($stars['half'] > 0)
                                    <svg class="w-5 h-5 text-yellow-400 fill-current" viewBox="0 0 20 20">
                                        <path d="M10 15l-5.878 3.09 1.123-6.545L.489 6.91l6.572-.955L10 0l2.939 5.955 6.572.955-4.756 4.635 1.123 6.545z" clip-path="inset(0 50% 0 0)"/>
                                    </svg>
                                @endif
                                @for($i = 0; $i < $stars['empty']; $i++)
                                    <svg class="w-5 h-5 text-gray-300 fill-current" viewBox="0 0 20 20">
                                        <path d="M10 15l-5.878 3.09 1.123-6.545L.489 6.91l6.572-.955L10 0l2.939 5.955 6.572.955-4.756 4.635 1.123 6.545z"/>
                                    </svg>
                                @endfor
                            </div>
                            <span class="text-sm font-semibold">{{ number_format($hotel->rating, 1) }}</span>
                        </div>
                    </div>
                    <div>
                        <p class="text-sm text-gray-500">Range Harga</p>
                        <p class="text-lg font-bold text-emerald-600">{{ $hotel->price_range }}</p>
                    </div>
                </div>
            </div>

            <!-- Contact Info -->
            @if($hotel->phone || $hotel->email || $hotel->address)
                <div class="bg-white rounded-lg border border-gray-200 p-6">
                    <h3 class="font-semibold text-gray-900 mb-4">📞 Kontak & Alamat</h3>
                    <div class="space-y-2">
                        @if($hotel->phone)
                            <div class="flex items-center gap-2">
                                <span class="text-sm text-gray-500 w-24">Telepon</span>
                                <span class="text-sm">{{ $hotel->phone }}</span>
                            </div>
                        @endif
                        @if($hotel->email)
                            <div class="flex items-center gap-2">
                                <span class="text-sm text-gray-500 w-24">Email</span>
                                <span class="text-sm">{{ $hotel->email }}</span>
                            </div>
                        @endif
                        @if($hotel->address)
                            <div class="flex items-start gap-2">
                                <span class="text-sm text-gray-500 w-24">Alamat</span>
                                <span class="text-sm">{{ $hotel->address }}</span>
                            </div>
                        @endif
                    </div>
                </div>
            @endif

            <!-- Check-in/Check-out -->
            <div class="bg-white rounded-lg border border-gray-200 p-6">
                <h3 class="font-semibold text-gray-900 mb-4">🕐 Waktu Check-in / Check-out</h3>
                <div class="flex items-center gap-4">
                    <div class="flex items-center gap-2">
                        <span class="text-sm text-gray-500">Check-in:</span>
                        <span class="font-semibold">{{ $hotel->check_in_time ?? '14:00' }}</span>
                    </div>
                    <span class="text-gray-300">|</span>
                    <div class="flex items-center gap-2">
                        <span class="text-sm text-gray-500">Check-out:</span>
                        <span class="font-semibold">{{ $hotel->check_out_time ?? '12:00' }}</span>
                    </div>
                </div>
            </div>

            <!-- Description -->
            @if($hotel->description)
                <div class="bg-white rounded-lg border border-gray-200 p-6">
                    <h3 class="font-semibold text-gray-900 mb-2">📝 Deskripsi</h3>
                    <p class="text-sm">{{ $hotel->description }}</p>
                </div>
            @endif

            <!-- Facilities -->
            @if($hotel->facilities && count($hotel->facilities) > 0)
                <div class="bg-white rounded-lg border border-gray-200 p-6">
                    <h3 class="font-semibold text-gray-900 mb-2">🎯 Fasilitas</h3>
                    <div class="flex flex-wrap gap-2">
                        @foreach($hotel->facilities as $facility)
                            <span class="inline-flex items-center px-3 py-1 rounded-full bg-blue-50 text-blue-700 text-xs font-medium">
                                {{ $facility }}
                            </span>
                        @endforeach
                    </div>
                </div>
            @endif

            <!-- Rooms -->
            <div class="bg-white rounded-lg border border-gray-200 p-6">
                <div class="flex items-center justify-between mb-4">
                    <h3 class="font-semibold text-gray-900">🛏️ Kamar Hotel ({{ $hotel->rooms->count() }})</h3>
                    <a href="{{ route('admin.rooms.create', ['hotel_id' => $hotel->id]) }}" 
                       class="inline-flex items-center px-3 py-1.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-xs font-medium transition">
                        <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
                        </svg>
                        Tambah Kamar
                    </a>
                </div>
                @if($hotel->rooms->count() > 0)
                    <div class="overflow-x-auto">
                        <table class="w-full text-sm">
                            <thead class="text-xs text-gray-500 uppercase bg-gray-50">
                                <tr>
                                    <th class="px-4 py-2 text-left">No. Kamar</th>
                                    <th class="px-4 py-2 text-left">Tipe</th>
                                    <th class="px-4 py-2 text-left">Harga/Malam</th>
                                    <th class="px-4 py-2 text-left">Kapasitas</th>
                                    <th class="px-4 py-2 text-left">Status</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-200">
                                @foreach($hotel->rooms->take(5) as $room)
                                    <tr>
                                        <td class="px-4 py-2 font-mono">{{ $room->room_number }}</td>
                                        <td class="px-4 py-2">{{ $room->room_type_label }}</td>
                                        <td class="px-4 py-2 text-emerald-600">Rp {{ number_format($room->price_per_night, 0, ',', '.') }}</td>
                                        <td class="px-4 py-2">{{ $room->capacity }} org</td>
                                        <td class="px-4 py-2">
                                            @if($room->is_available)
                                                <span class="text-emerald-600 text-xs font-semibold">✅ Tersedia</span>
                                            @else
                                                <span class="text-red-600 text-xs font-semibold">❌ Tidak Tersedia</span>
                                            @endif
                                        </td>
                                    </tr>
                                @endforeach
                            </tbody>
                        </table>
                        @if($hotel->rooms->count() > 5)
                            <p class="text-xs text-gray-400 mt-2">... dan {{ $hotel->rooms->count() - 5 }} kamar lainnya</p>
                        @endif
                    </div>
                @else
                    <p class="text-sm text-gray-400">Belum ada kamar untuk hotel ini. 
                        <a href="{{ route('admin.rooms.create', ['hotel_id' => $hotel->id]) }}" class="text-blue-600 hover:underline">Tambah kamar sekarang</a>
                    </p>
                @endif
            </div>
        </div>

        <!-- Sidebar -->
        <div class="lg:col-span-1 space-y-6">
            <!-- Photo -->
            <div class="bg-white rounded-lg border border-gray-200 p-6">
                <h3 class="font-semibold text-gray-900 mb-4">🖼️ Foto Hotel</h3>
                @if($hotel->image)
                    <img src="{{ asset('storage/hotels/' . $hotel->image) }}" 
                         alt="{{ $hotel->name }}" 
                         class="w-full rounded-lg border border-gray-200">
                @else
                    <div class="w-full h-48 bg-gray-100 rounded-lg border border-gray-200 flex items-center justify-center text-gray-400">
                        <svg class="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                        </svg>
                    </div>
                @endif
            </div>

            <!-- Actions -->
            <div class="bg-gray-50 rounded-lg border border-gray-200 p-6">
                <h3 class="font-semibold text-gray-900 mb-4">⚙️ Aksi</h3>
                <div class="space-y-3">
                    <a href="{{ route('admin.hotels.edit', $hotel->id) }}" 
                       class="block w-full bg-amber-600 hover:bg-amber-700 text-white text-center font-medium py-2 rounded-lg transition">
                        ✏️ Edit Hotel
                    </a>
                    <a href="{{ route('admin.rooms.create', ['hotel_id' => $hotel->id]) }}" 
                       class="block w-full bg-purple-600 hover:bg-purple-700 text-white text-center font-medium py-2 rounded-lg transition">
                        🛏️ Tambah Kamar
                    </a>
                    <a href="{{ route('admin.rooms.index', ['hotel_id' => $hotel->id]) }}" 
                       class="block w-full bg-blue-600 hover:bg-blue-700 text-white text-center font-medium py-2 rounded-lg transition">
                        📋 Kelola Kamar
                    </a>
                    <form action="{{ route('admin.hotels.destroy', $hotel->id) }}" method="POST" 
                          onsubmit="return confirm('Apakah Anda yakin ingin menghapus hotel ini? Semua kamar akan terhapus.')">
                        @csrf
                        @method('DELETE')
                        <button type="submit" class="block w-full bg-red-600 hover:bg-red-700 text-white font-medium py-2 rounded-lg transition">
                            🗑️ Hapus Hotel
                        </button>
                    </form>
                </div>
            </div>

            <!-- Information -->
            <div class="bg-white rounded-lg border border-gray-200 p-6">
                <h3 class="font-semibold text-gray-900 mb-4">📌 Informasi</h3>
                <div class="space-y-2 text-sm">
                    <div class="flex justify-between">
                        <span class="text-gray-500">Dibuat</span>
                        <span>{{ $hotel->created_at->format('d M Y H:i') }}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-gray-500">Diperbarui</span>
                        <span>{{ $hotel->updated_at->format('d M Y H:i') }}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-gray-500">Total Kamar</span>
                        <span>{{ $hotel->rooms->count() }}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-gray-500">Harga Termurah</span>
                        <span class="text-emerald-600">Rp {{ number_format($hotel->min_price, 0, ',', '.') }}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-gray-500">Harga Termahal</span>
                        <span class="text-emerald-600">Rp {{ number_format($hotel->max_price, 0, ',', '.') }}</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection