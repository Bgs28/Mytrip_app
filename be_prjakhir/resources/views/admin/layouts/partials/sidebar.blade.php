{{-- resources/views/admin/layouts/sidebar.blade.php --}}

<aside id="sidebar" class="w-64 bg-blue-900 text-white flex flex-col shadow-xl md:flex hidden">
    <div class="p-6 border-b border-blue-800 flex items-center justify-between">
        <h1 class="text-xl font-bold tracking-wider">MYTRIP ADMIN</h1>
        <button id="closeSidebar" class="md:hidden text-white hover:text-gray-300">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
        </button>
    </div>
    <nav class="flex-1 p-4 space-y-2">
        <a href="{{ route('admin.dashboard') }}" 
           class="flex items-center px-4 py-3 rounded-xl font-medium transition-all {{ request()->routeIs('admin.dashboard') ? 'bg-blue-800 text-white' : 'text-blue-200 hover:bg-blue-800 hover:text-white' }}">
            <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zm10 0a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zm10 0a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"></path>
            </svg>
            <span>Dashboard</span>
        </a>

        <a href="{{ route('admin.users.index') }}" 
           class="flex items-center px-4 py-3 rounded-xl font-medium transition-all {{ request()->routeIs('admin.users.*') ? 'bg-blue-800 text-white' : 'text-blue-200 hover:bg-blue-800 hover:text-white' }}">
            <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"></path>
            </svg>
            <span>Data User</span>
        </a>

        <!-- Menu Hotel dengan Submenu -->
        <div class="space-y-1">
            <div class="flex items-center justify-between px-4 py-3 rounded-xl font-medium transition-all cursor-pointer hover:bg-blue-800 hover:text-white
                {{ request()->routeIs('admin.hotels.*') || request()->routeIs('admin.rooms.*') ? 'bg-blue-800 text-white' : 'text-blue-200' }}"
                onclick="toggleSubmenu('hotelMenu')">
                <div class="flex items-center">
                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path>
                    </svg>
                    <span>Data Hotel</span>
                </div>
                <svg id="hotelMenuArrow" class="w-4 h-4 transition-transform duration-200 {{ request()->routeIs('admin.hotels.*') || request()->routeIs('admin.rooms.*') ? 'rotate-180' : '' }}" 
                     fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                </svg>
            </div>
            <div id="hotelMenu" class="ml-4 space-y-1 {{ request()->routeIs('admin.hotels.*') || request()->routeIs('admin.rooms.*') ? '' : 'hidden' }}">
                <a href="{{ route('admin.hotels.index') }}" 
                   class="flex items-center px-4 py-2 rounded-xl text-sm font-medium transition-all {{ request()->routeIs('admin.hotels.*') && !request()->routeIs('admin.rooms.*') ? 'bg-blue-700 text-white' : 'text-blue-200 hover:bg-blue-700 hover:text-white' }}">
                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path>
                    </svg>
                    Daftar Hotel
                </a>
                <a href="{{ route('admin.rooms.index') }}" 
                   class="flex items-center px-4 py-2 rounded-xl text-sm font-medium transition-all {{ request()->routeIs('admin.rooms.*') ? 'bg-blue-700 text-white' : 'text-blue-200 hover:bg-blue-700 hover:text-white' }}">
                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4"></path>
                    </svg>
                    Kelola Kamar
                </a>
            </div>
        </div>
<!-- 
        <a href="{{ route('admin.trains.index') }}" 
           class="flex items-center px-4 py-3 rounded-xl font-medium transition-all {{ request()->routeIs('admin.trains.*') ? 'bg-blue-800 text-white' : 'text-blue-200 hover:bg-blue-800 hover:text-white' }}">
            <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 21h8m-4-4v4"></path>
            </svg>
            <span>Data Kereta</span>
        </a>

        <a href="{{ route('admin.buses.index') }}" 
           class="flex items-center px-4 py-3 rounded-xl font-medium transition-all {{ request()->routeIs('admin.buses.*') ? 'bg-blue-800 text-white' : 'text-blue-200 hover:bg-blue-800 hover:text-white' }}">
            <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h8M8 11h8M8 15h8M4 7a2 2 0 012-2h12a2 2 0 012 2v10a2 2 0 01-2 2H6a2 2 0 01-2-2V7z"></path>
            </svg>
            <span>Data Bus</span>
        </a> -->
        <!-- Menu Kereta dengan Submenu -->
        <div class="space-y-1">
            <div class="flex items-center justify-between px-4 py-3 rounded-xl font-medium transition-all cursor-pointer hover:bg-blue-800 hover:text-white
                {{ request()->routeIs('admin.trains.*') || request()->routeIs('admin.train-seats.*') ? 'bg-blue-800 text-white' : 'text-blue-200' }}"
                onclick="toggleSubmenu('trainMenu')">
                <div class="flex items-center">
                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 21h8m-4-4v4"></path>
                    </svg>
                    <span>Data Kereta</span>
                </div>
                <svg id="trainMenuArrow" class="w-4 h-4 transition-transform duration-200 {{ request()->routeIs('admin.trains.*') || request()->routeIs('admin.train-seats.*') ? 'rotate-180' : '' }}" 
                    fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                </svg>
            </div>
            <div id="trainMenu" class="ml-4 space-y-1 {{ request()->routeIs('admin.trains.*') || request()->routeIs('admin.train-seats.*') ? '' : 'hidden' }}">
                <a href="{{ route('admin.trains.index') }}" 
                class="flex items-center px-4 py-2 rounded-xl text-sm font-medium transition-all {{ request()->routeIs('admin.trains.*') && !request()->routeIs('admin.train-seats.*') ? 'bg-blue-700 text-white' : 'text-blue-200 hover:bg-blue-700 hover:text-white' }}">
                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 21h8m-4-4v4"></path>
                    </svg>
                    Daftar Kereta
                </a>
                <a href="{{ route('admin.train-seats.index') }}" 
                class="flex items-center px-4 py-2 rounded-xl text-sm font-medium transition-all {{ request()->routeIs('admin.train-seats.*') ? 'bg-blue-700 text-white' : 'text-blue-200 hover:bg-blue-700 hover:text-white' }}">
                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h8M8 11h8M8 15h8M4 7a2 2 0 012-2h12a2 2 0 012 2v10a2 2 0 01-2 2H6a2 2 0 01-2-2V7z"></path>
                    </svg>
                    Kelola Kursi
                </a>
            </div>
        </div>

        <!-- Menu Bus dengan Submenu -->
        <div class="space-y-1">
            <div class="flex items-center justify-between px-4 py-3 rounded-xl font-medium transition-all cursor-pointer hover:bg-blue-800 hover:text-white
                {{ request()->routeIs('admin.buses.*') || request()->routeIs('admin.bus-seats.*') ? 'bg-blue-800 text-white' : 'text-blue-200' }}"
                onclick="toggleSubmenu('busMenu')">
                <div class="flex items-center">
                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h8M8 11h8M8 15h8M4 7a2 2 0 012-2h12a2 2 0 012 2v10a2 2 0 01-2 2H6a2 2 0 01-2-2V7z"></path>
                    </svg>
                    <span>Data Bus</span>
                </div>
                <svg id="busMenuArrow" class="w-4 h-4 transition-transform duration-200 {{ request()->routeIs('admin.buses.*') || request()->routeIs('admin.bus-seats.*') ? 'rotate-180' : '' }}" 
                    fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                </svg>
            </div>
            <div id="busMenu" class="ml-4 space-y-1 {{ request()->routeIs('admin.buses.*') || request()->routeIs('admin.bus-seats.*') ? '' : 'hidden' }}">
                <a href="{{ route('admin.buses.index') }}" 
                class="flex items-center px-4 py-2 rounded-xl text-sm font-medium transition-all {{ request()->routeIs('admin.buses.*') && !request()->routeIs('admin.bus-seats.*') ? 'bg-blue-700 text-white' : 'text-blue-200 hover:bg-blue-700 hover:text-white' }}">
                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h8M8 11h8M8 15h8M4 7a2 2 0 012-2h12a2 2 0 012 2v10a2 2 0 01-2 2H6a2 2 0 01-2-2V7z"></path>
                    </svg>
                    Daftar Bus
                </a>
                <a href="{{ route('admin.bus-seats.index') }}" 
                class="flex items-center px-4 py-2 rounded-xl text-sm font-medium transition-all {{ request()->routeIs('admin.bus-seats.*') ? 'bg-blue-700 text-white' : 'text-blue-200 hover:bg-blue-700 hover:text-white' }}">
                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h8M8 11h8M8 15h8M4 7a2 2 0 012-2h12a2 2 0 012 2v10a2 2 0 01-2 2H6a2 2 0 01-2-2V7z"></path>
                    </svg>
                    Kelola Kursi
                </a>
            </div>
        </div>

        <a href="{{ route('admin.booking.index') }}" 
           class="flex items-center px-4 py-3 rounded-xl font-medium transition-all {{ request()->routeIs('admin.booking.*') ? 'bg-blue-800 text-white' : 'text-blue-200 hover:bg-blue-800 hover:text-white' }}">
            <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
            </svg>
            <span>Data Booking</span>
        </a>

        <a href="{{ route('admin.promo.index') }}" 
           class="flex items-center px-4 py-3 rounded-xl font-medium transition-all {{ request()->routeIs('admin.promo.*') ? 'bg-blue-800 text-white' : 'text-blue-200 hover:bg-blue-800 hover:text-white' }}">
            <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v13m0-13V6a2 2 0 112 2h-2zm0 0V5.5A2.5 2.5 0 109.5 8H12zm-7 4h14M5 12a2 2 0 110-4h14a2 2 0 110 4M5 12v7a2 2 0 002 2h10a2 2 0 002-2v-7"></path>
            </svg>
            <span>Data Promo</span>
        </a>
    </nav>
</aside>

<!-- Mobile Sidebar Toggle -->
<button id="openSidebar" class="md:hidden fixed top-4 left-4 z-50 p-2 bg-blue-900 text-white rounded-lg shadow-lg hover:bg-blue-800 transition">
    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
    </svg>
</button>

<!-- Mobile Overlay -->
<div id="sidebarOverlay" class="fixed inset-0 bg-black bg-opacity-50 z-40 hidden md:hidden" onclick="closeSidebar()"></div>

<script>
    function toggleSubmenu(menuId) {
        const menu = document.getElementById(menuId);
        const arrow = document.getElementById(menuId + 'Arrow');
        if (menu) {
            menu.classList.toggle('hidden');
            if (arrow) {
                arrow.classList.toggle('rotate-180');
            }
        }
    }

    function openSidebar() {
        document.getElementById('sidebar').classList.remove('hidden');
        document.getElementById('sidebar').classList.add('fixed', 'inset-y-0', 'left-0', 'z-50');
        document.getElementById('sidebarOverlay').classList.remove('hidden');
    }

    function closeSidebar() {
        document.getElementById('sidebar').classList.add('hidden');
        document.getElementById('sidebar').classList.remove('fixed', 'inset-y-0', 'left-0', 'z-50');
        document.getElementById('sidebarOverlay').classList.add('hidden');
    }

    document.getElementById('openSidebar')?.addEventListener('click', openSidebar);
    document.getElementById('closeSidebar')?.addEventListener('click', closeSidebar);

    // Auto close on route change for mobile
    document.querySelectorAll('#sidebar a').forEach(link => {
        link.addEventListener('click', () => {
            if (window.innerWidth < 768) {
                closeSidebar();
            }
        });
    });

    // Handle responsive
    window.addEventListener('resize', function() {
        if (window.innerWidth >= 768) {
            closeSidebar();
            document.getElementById('sidebar').classList.remove('fixed', 'inset-y-0', 'left-0', 'z-50');
            document.getElementById('sidebar').classList.remove('hidden');
        }
    });
</script>