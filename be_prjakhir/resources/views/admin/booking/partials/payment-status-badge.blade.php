{{-- resources/views/admin/booking/partials/payment-status-badge.blade.php --}}
@if($status == 'pending')
    <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-orange-100 text-orange-800 text-xs font-semibold">
        🔄 Menunggu Verifikasi
    </span>
@elseif($status == 'paid')
    <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-emerald-100 text-emerald-800 text-xs font-semibold">
        ✅ Paid
    </span>
@elseif($status == 'failed')
    <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-red-100 text-red-800 text-xs font-semibold">
        ❌ Failed
    </span>
@elseif($status == 'refunded')
    <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-gray-100 text-gray-800 text-xs font-semibold">
        ↩️ Refunded
    </span>
@else
    <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-gray-100 text-gray-800 text-xs font-semibold">
        {{ ucfirst($status) }}
    </span>
@endif