<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Admin Dashboard') - MyTrip</title>
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
</head>
<body class="bg-blue-50 text-gray-800 font-sans antialiased">

    <div class="flex min-h-screen">
        @include('admin.layouts.partials.sidebar')

        <div class="flex-1 flex flex-col">
            @include('admin.layouts.partials.navbar')

            <main class="p-6 md:p-8 flex-grow">
                @yield('content')
            </main>
        </div>
    </div>

</body>
</html>