using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;


public class CoinPickup : MonoBehaviour
{

    [SerializeField] AudioClip coinPickUpSFX;
    [SerializeField] int pointsForCoinPickup = 50;

    [SerializeField] bool isUniqueObject;
    string emailToSend = "";
    string url = "";
    string id = "";


    private void OnTriggerEnter2D(Collider2D collision)
    {

        if (collision.GetType() == typeof(CapsuleCollider2D))
        {

            FindObjectOfType<GameSession>().AddToScore(pointsForCoinPickup);
            AudioSource.PlayClipAtPoint(coinPickUpSFX, Camera.main.transform.position);

        }

        if (isUniqueObject)
        {


            emailToSend = FindObjectOfType<GameSession>().getEmail();
            id = gameObject.name;

            url = "http://localhost:3001/query/transaction?email=" + emailToSend + "&id=" + id;

            StartCoroutine(ChangeOwnerOnBlockchain());

            //CALL TO SMART CONTRACT TO CHANGE OWNER FORM ADMIN TO PLAYER
        }

        Destroy(gameObject);
    }



    IEnumerator ChangeOwnerOnBlockchain()
    {


        WWWForm form = new WWWForm();

        UnityWebRequest www = UnityWebRequest.Get(url);
        yield return www.SendWebRequest();



        if (www.isNetworkError || www.isHttpError)
        {
            Debug.Log(www.error);
        }
        else
        {
            Debug.Log(www.downloadHandler.text.ToString());
            if (www.downloadHandler.text == "Login effettuato con successo")
            {

                Debug.Log("Change Owner Complete complete!");


            }


        }
    }
}
