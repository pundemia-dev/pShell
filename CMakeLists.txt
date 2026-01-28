cmake_minimum_required(VERSION 3.19)

# 1. Настройка проекта и версии.
# В оригинале версия бралась из git. Здесь мы ставим фиксированную версию для старта.
# Эта переменная ${VERSION} критична, она пробрасывается внутрь плагина.
project(my-shell-project VERSION 0.1.0 LANGUAGES CXX)

# 2. Настройка стандарта C++.
# Плагин написан на C++20, без этого флага сборка упадет.
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# 3. Пути установки (Install Paths).
# Это САМАЯ важная часть для плагина.
# Скрипт внутри плагина использует ${INSTALL_QMLDIR}, чтобы знать, куда класть бинарники.
# Если вы не зададите это здесь, установка (make install) сломается.
include(GNUInstallDirs)

if(NOT DEFINED INSTALL_QMLDIR)
    # Стандартный путь для Linux/Qt6.
    # Если у вас нестандартная установка Qt, измените этот путь.
    set(INSTALL_QMLDIR "${CMAKE_INSTALL_LIBDIR}/qt6/qml" CACHE PATH "QML install dir")
endif()

# Опционально: Путь для библиотек (если плагин ставит .so отдельно)
if(NOT DEFINED INSTALL_LIBDIR)
    set(INSTALL_LIBDIR "${CMAKE_INSTALL_LIBDIR}/caelestia" CACHE STRING "Library install dir")
endif()

# 4. Флаги компилятора.
# Скопированы из оригинала. Они включают строгие проверки.
# Если сборка будет ругаться на предупреждения, можно закомментировать этот блок.
add_compile_options(
    -Wall -Wextra -Wpedantic -Wshadow -Wconversion
    -Wold-style-cast -Wnull-dereference -Wdouble-promotion
    -Wformat=2 -Wfloat-equal -Woverloaded-virtual
    -Wsign-conversion -Wredundant-decls -Wswitch
    -Wunreachable-code
)

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    add_compile_options(-Wunused-lambda-capture)
endif()

# 5. Поиск основных зависимостей.
# Лучше проверить наличие Qt сразу в корне.
find_package(Qt6 REQUIRED COMPONENTS Core Qml Gui Quick Concurrent Sql Network DBus)
find_package(PkgConfig REQUIRED)

# 6. Подключение плагина.
# Предполагается, что папка "plugin" лежит в той же директории, что и этот файл.
add_subdirectory(plugin)
