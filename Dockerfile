FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["src/ProjectName.Api/ProjectName.Api.csproj", "src/ProjectName.Api/"]
RUN dotnet restore "src/ProjectName.Api/ProjectName.Api.csproj"
COPY . .
WORKDIR "/src/src/ProjectName.Api"
RUN dotnet build "ProjectName.Api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ProjectName.Api.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ProjectName.Api.dll"]

