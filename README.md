# Noah Studio - Event Photography & Videography Booking System

A complete Java JSP/Servlet web application built with MVC architecture and Object-Oriented Programming (OOP) principles. The system uses text-file persistence (no database required).

## 🚀 How to Run in IntelliJ IDEA

### 1. Prerequisites
* **JDK 1.8 or higher** installed.
* **Apache Tomcat** (Version 9.x recommended) installed on your machine.

### 2. Project Setup
1. Open **IntelliJ IDEA**.
2. Go to `File` > `New` > `Project from Existing Sources...`.
3. Select the `Noah. Studio` folder.
4. Choose **"Import project from external model"** and select **"Maven"** (if using a pom.xml) or simply click **"Next"** until finished if it's a standard Web project.

### 3. Configure Tomcat Server
1. Click on **"Add Configuration"** (top right) or `Run` > `Edit Configurations`.
2. Click the `+` icon and select **"Tomcat Server"** > **"Local"**.
3. In the **"Deployment"** tab, click the `+` icon and select **"Artifact"**.
4. Choose the `Noah. Studio:war exploded` (or equivalent).
5. Set the **Application context** to `/NoahStudio`.
6. Click **Apply** and **OK**.

### 4. Running the App
1. Click the green **Run** button.
2. The application will open at `http://localhost:8080/NoahStudio/`.

---

## 🔑 Demo Credentials
| Role | Username | Password |
| :--- | :--- | :--- |
| **Admin** | `admin` | `admin123` |
| **Client** | `sarah` | `password123` |

## 📁 System Architecture
* **Model**: Java classes in `com.noahstudio.model` (User, Booking, etc.) implementing Inheritance and Encapsulation.
* **Controller**: Servlets in `com.noahstudio.servlet` handling logic and session management.
* **View**: JSP pages in `webapp` folder styled with a premium CSS system.
* **Data**: Pipe-delimited text files in the `data/` directory.

## ✨ Features
* **User Management**: Registration, Login (Sessions), and Admin CRUD.
* **Booking System**: Create bookings, update statuses (Confirmed/Completed).
* **Package Management**: Admin can add/edit photography packages.
* **Portfolio**: Grid gallery with category filtering.
* **Payments**: Recording and tracking payment statuses.
* **Reviews**: Star-rating system for client feedback.
