<aside class="w-64 bg-blue-900 text-white flex flex-col shadow-xl hidden md:flex">
    <div class="p-6 border-b border-blue-800">
        <h1 class="text-xl font-bold tracking-wider">MYTRIP ADMIN</h1>
    </div>
    <nav class="flex-1 p-4 space-y-2">
        <a href="{{ route('admin.dashboard')}}" class="flex items-center px-4 py-3 bg-blue-800 rounded-xl text-white font-medium transition-all">
            <span>Dashboard</span>
        </a>
        <a href="{{ route('admin.users.index') }}" class="flex items-center px-4 py-3 text-blue-200 hover:bg-blue-800 hover:text-white rounded-xl transition-all">
            <span>Data User</span>
        </a>
        <a href="{{ route('admin.hotels.index') }}" class="flex items-center px-4 py-3 rounded-xl font-medium transition-all {{ request()->routeIs('admin.hotels.*') ? 'bg-blue-800 text-white' : 'text-blue-200 hover:bg-blue-800 hover:text-white' }}">
            <span>Data Hotel</span>
        </a>
        <a href="{{ route('admin.trains.index') }}" class="flex items-center px-4 py-3 rounded-xl font-medium transition-all {{ request()->routeIs('admin.hotels.*') ? 'bg-blue-800 text-white' : 'text-blue-200 hover:bg-blue-800 hover:text-white' }}">
            <span>Data Kereta</span>
        </a>
        <a href="{{ route('admin.buses.index') }}" class="flex items-center px-4 py-3 rounded-xl font-medium transition-all {{ request()->routeIs('admin.hotels.*') ? 'bg-blue-800 text-white' : 'text-blue-200 hover:bg-blue-800 hover:text-white' }}">
            <span>Data Bus</span>
        </a>
        <a href="{{ route('admin.booking.index') }}" class="flex items-center px-4 py-3 rounded-xl font-medium transition-all {{ request()->routeIs('admin.hotels.*') ? 'bg-blue-800 text-white' : 'text-blue-200 hover:bg-blue-800 hover:text-white' }}">
            <span>Data Booking</span>
        </a>
        <a href="{{ route('admin.promo.index') }}" class="flex items-center px-4 py-3 rounded-xl font-medium transition-all {{ request()->routeIs('admin.hotels.*') ? 'bg-blue-800 text-white' : 'text-blue-200 hover:bg-blue-800 hover:text-white' }}">
            <span>Data Promo</span>
        </a>
    </nav>
</aside>