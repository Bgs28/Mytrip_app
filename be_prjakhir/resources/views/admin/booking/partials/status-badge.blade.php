{{-- resources/views/admin/booking/partials/status-badge.blade.php --}}
@if($status == 'pending')
    <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-yellow-100 text-yellow-800 text-xs font-semibold">
        ⏳ Pending
    </span>
@elseif($status == 'paid')
    <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-emerald-100 text-emerald-800 text-xs font-semibold">
        ✅ Paid
    </span>
@elseif($status == 'cancel')
    <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-rose-100 text-rose-800 text-xs font-semibold">
        ❌ Cancelled
    </span>
@else
    <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-gray-100 text-gray-800 text-xs font-semibold">
        {{ ucfirst($status) }}
    </span>
@endif