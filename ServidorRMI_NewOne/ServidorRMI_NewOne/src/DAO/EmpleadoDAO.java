/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO;

import Interfaces.IGestionEmpleadosRemoto; 
import entidades.Empleados;
import conexion.connectionDrive;
import java.rmi.RemoteException;
import java.rmi.server.UnicastRemoteObject;
import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;

public class EmpleadoDAO extends UnicastRemoteObject implements IGestionEmpleadosRemoto {

    public EmpleadoDAO() throws RemoteException {
        super();
    }

    @Override
    public List<Empleados> listarEmpleados() throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        try {
            List<Empleados> lista = em.createQuery("SELECT e FROM Empleados e", Empleados.class).getResultList();
            for (Empleados e : lista) {
                em.detach(e);
                e.setPedidosList(null);
            }
            return lista;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }

    @Override
    public Empleados buscarEmpleadoPorId(int idUsuario) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        try {
            Empleados e = em.find(Empleados.class, idUsuario);
            if (e != null) {
                em.detach(e);
                e.setPedidosList(null);
            }
            return e;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }

    @Override
    public boolean registrarEmpleado(Empleados empleado) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(empleado);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }

    @Override
    public boolean actualizarEmpleado(Empleados empleado) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.merge(empleado);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }

    @Override
    public boolean eliminarEmpleado(int idUsuario) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Empleados emp = em.find(Empleados.class, idUsuario);
            if (emp != null) {
                em.remove(emp);
                tx.commit();
                return true;
            }
            return false;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }
}
