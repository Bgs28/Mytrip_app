@extends('admin.layouts.admin')

@section('title', 'Kelola Bus')

@section('content')
<div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <div>
            <h1 class="text-xl font-bold text-gray-900">Kelola Jadwal Otobus (Bus)</h1>
            <p class="text-sm text-gray-500 mt-1">Daftar rute perjalanan bus dan kapasitas kursi aplikasi MyTrip</p>
        </div>
        <a href="{{ route('admin.buses.create') }}" class="inline-flex items-center justify-center bg-blue-600 hover:bg-blue-700 text-white font-medium px-4 py-2.5 rounded-lg transition shadow-sm text-sm gap-2">
            Tambah Rute Bus
        </a>
    </div>

    @if(session('success'))
        <div class="mb-6 p-4 bg-emerald-50 border border-emerald-200 text-emerald-800 rounded-lg text-sm">
            {{ session('success') }}
        </div>
    @endif

    <div class="overflow-x-auto rounded-lg border border-gray-200">
        <table class="w-full text-left border-collapse bg-white text-sm text-gray-500">
            <thead class="bg-gray-50 text-xs font-semibold uppercase text-gray-700 border-b border-gray-200">
                <tr>
                    <th class="px-6 py-4 text-center w-16">No</th>
                    <th class="px-6 py-4">Nama Bus PO</th>
                    <th class="px-6 py-4">Rute (Asal → Tujuan)</th>
                    <th class="px-6 py-4">Jam Berangkat</th>
                    <th class="px-6 py-4">Harga Tiket</th>
                    <th class="px-6 py-4 text-center">Kursi</th>
                    <th class="px-6 py-4 text-center w-44">Aksi</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                @forelse($buses as $index => $bus)
                <tr class="hover:bg-gray-50 transition">
                    <td class="px-6 py-4 text-center font-medium text-gray-900">{{ $buses->firstItem() + $index }}</td>
                    <td class="px-6 py-4 font-semibold text-gray-900">{{ $bus->bus_name }}</td>
                    <td class="px-6 py-4 text-gray-600">
                        <span class="font-medium text-gray-800">{{ $bus->from }}</span> → <span class="font-medium text-gray-800">{{ $bus->destination }}</span>
                    </td>
                    <td class="px-6 py-4 text-gray-600">
                        🕒 {{ \Carbon\Carbon::parse($bus->departure_time)->format('H:i') }} WIB
                    </td>
                    <td class="px-6 py-4 text-blue-600 font-medium">Rp {{ number_format($bus->price, 0, ',', '.') }}</td>
                    <td class="px-6 py-4 text-center">
                        <span class="bg-indigo-50 text-indigo-700 px-2.5 py-1 rounded-md font-bold text-xs">
                            {{ $bus->seat }} Tersedia
                        </span>
                    </td>
                    <td class="px-6 py-4 text-center">
                        <div class="flex items-center justify-center gap-2">
                            <a href="{{ route('admin.buses.edit', $bus->id) }}" class="px-3 py-1.5 bg-amber-50 border border-amber-200 text-amber-700 rounded-md text-xs font-medium transition hover:bg-amber-100">Edit</a>
                            <form action="{{ route('admin.buses.destroy', $bus->id) }}" method="POST" class="inline" onsubmit="return confirm('Hapus rute bus ini?')">
                                @csrf @method('DELETE')
                                <button type="submit" class="px-3 py-1.5 bg-rose-50 border border-rose-200 text-rose-700 rounded-md text-xs font-medium transition hover:bg-rose-100">Hapus</button>
                            </form>
                        </div>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="7" class="px-6 py-10 text-center text-gray-400">Jadwal armada bus belum tersedia.</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="mt-6">
        {{ $buses->links() }}
    </div>
</div>
@endsection