
# Etapa 1: Construccion
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

WORKDIR /src

COPY ["App.Redis.Api.csproj", "./"]

RUN dotnet restore "App.Redis.Api.csproj"

COPY . .

RUN dotnet publish "App.Redis.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Etapa 2: Imagen final
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final

WORKDIR /app

COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8080

EXPOSE 8080

ENTRYPOINT ["dotnet", "App.Redis.Api.dll"]
